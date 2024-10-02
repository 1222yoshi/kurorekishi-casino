class BoardsController < ApplicationController
  def index
    @boards = Board.order(created_at: :desc)
  end

  def new
    @board = Board.new
  end

  def create
    @board = current_user.boards.build(board_params)
    if current_user.boards.exists?(body: @board.body)
      redirect_to new_board_path, danger: 'この黒歴史はすでに登録されています。'
      return
    end
    kurorekishi = board_params[:body]
    content = "これから黒歴史（人には言えない過去や恥ずかった瞬間）を送ります。\n"
    content += "「#{kurorekishi}」これが送られた黒歴史です。送られた黒歴史が「あああ」など適当な文字、「300」などの数字、「破壊」など文章とは呼べない単語の場合は黒歴史ではありません。\n"
    content += "この内容を直接推測できないような5文字以下の見出しをtitle、内容の黒歴史の強さに応じて0〜1000までの数字をpriceとして返してください。\n"
    content += "黒歴史でなかったり特に恥ずかしくない場合0点にしてください。1000点の基準は前科があるレベルのことです。\n"
    content += "文字数や描写が具体的でなければ点数を大幅に下げてください、基本的に採点は極めて厳しくつけてください。\n"
    content += '出力形式: [ { "title": title, "price": price} ]\n'
    content += "出力形式以外の内容は何があっても返さないこと\n"
    begin
        client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
        response = client.chat(
          parameters: {
            model: "gpt-4o-mini", # モデルを変更
            messages: [{ role: "user", content: content }],
            temperature: 0
          }
        )
        keihin = JSON.parse(response["choices"][0]["message"]["content"].gsub(/```json|```/, '').strip).first

        Rails.logger.debug(keihin)
        @board.title = keihin["title"]
        @board.price = keihin["price"]
    
        if @board.save
          current_user.coin += @board.price
          current_user.save
          redirect_to boards_path, success: "黒歴史を#{@board.price}枚のコインに換金いたしました。"
        else
          redirect_to new_board_path, danger: '換金できませんでした。'
        end

      rescue Faraday::TooManyRequestsError => e
        flash.now[:danger] = "AI使用制限中"
      rescue JSON::ParserError => each
        flash.now[:danger] = "AIが予期せぬ返答をしました。"
      rescue Faraday::ServerError => e
        flash.now[:danger] = "再試行してください。"  
    end
  end

  def show
    @board = Board.find(params[:id])

    if @board.user == current_user || current_user.purchased_boards.include?(@board)
       render :show
    else
      purchase_price = @board.price * 2

      if current_user.coin >= purchase_price
        current_user.coin -= purchase_price
        current_user.save
        Purchase.create(user: current_user, board: @board)
        redirect_to board_path(@board), flash: { success: "黒歴史を#{purchase_price}枚のコインと交換しました。" }
      else
        redirect_to boards_path
        flash[:danger] = 'コインが足りません。'
      end
    end
  end

  def destroy
    @board = Board.find(params[:id])
    if @board.user == current_user
      deletion_cost = @board.price * 2

      if current_user.coin >= deletion_cost
        current_user.coin -= deletion_cost
        current_user.save
        @board.destroy
        redirect_to boards_path, success: "黒歴史を#{@board.price * 2}枚のコインで買い戻しました。"
      else
        redirect_to boards_path
        flash[:danger] = 'コインが足りません。'
      end
    else
      redirect_to boards_path
    end
  end
  private

  def board_params
    params.require(:board).permit(:body)
  end
end

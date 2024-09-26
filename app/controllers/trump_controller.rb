class TrumpController < ApplicationController
  def index
    @hidden_cards = [] # 最初は空の配列
    session[:deck_id] = nil
    session[:visible_card] = nil
    session[:hidden_cards] = nil
  end

  def start_game
    if session[:deck_id].nil? # デッキIDがセッションに保存されていないときだけ新しいデッキを作成
      response = HTTParty.post('https://deckofcardsapi.com/api/deck/new/shuffle/')
      session[:deck_id] = response.parsed_response['deck_id']
    end
    input_coin = params[:coin].to_i
    if current_user.coin >= input_coin
      current_user.coin -= input_coin
      current_user.save
      session[:bet_coin] = input_coin
      draw_initial_cards
      redirect_to action: :show
    elsif current_user.coin == 0
      redirect_to new_board_path, danger: 'コインをお持ちでないようです。黒歴史を売りますか？'
    else
      redirect_to trump_index_path, danger: 'コインが足りません。'
    end
  end

  def show
    @visible_card = session[:visible_card]
    @hidden_cards = session[:hidden_cards]
    @shuffle_cards = @hidden_cards.shuffle
    if rand < 1.0 / 3.0
      # 1/3の確率でそれ以外の情報を取り出す
      other_cards = @hidden_cards[1..-1] # 最初のカード以外を取得
      @selected_card = other_cards.sample # ランダムに選択
    else
      # 最初のカードを取り出す
      @selected_card = @hidden_cards.first
    end
  end

  def draw_initial_cards
    @deck_id = session[:deck_id]

  # セッションにカードが保存されていない場合にのみ新しいカードを引く
    if session[:visible_card].nil? || session[:hidden_cards].nil?
      if current_user.equipped.any? { |equipped_skill| equipped_skill.name == "V.I.P" } 
        session[:hidden_cards] ||= []
        while session[:hidden_cards].length < 4
          response = HTTParty.get("https://deckofcardsapi.com/api/deck/#{@deck_id}/draw/?count=1")
          card = response.parsed_response['cards'].first
          if card_value(card) == 14
            session[:hidden_cards] << card
          end
        end
        response = HTTParty.get("https://deckofcardsapi.com/api/deck/#{@deck_id}/draw/?count=1")
        session[:visible_card] = response.parsed_response['cards'].first
      else
        response = HTTParty.get("https://deckofcardsapi.com/api/deck/#{@deck_id}/draw/?count=1")
        session[:visible_card] = response.parsed_response['cards'].first

        if current_user.equipped.any? { |equipped_skill| equipped_skill.name == "勝利の女神" } || (current_user.equipped.any? { |equipped_skill| equipped_skill.name == "悪魔の契約" } && current_user.coin == 0)
          session[:hidden_cards] ||= []
          while session[:hidden_cards].length < 3
            response = HTTParty.get("https://deckofcardsapi.com/api/deck/#{@deck_id}/draw/?count=1")
            card = response.parsed_response['cards'].first
            if card_value(card) >= card_value(session[:visible_card])
              session[:hidden_cards] << card
            end
          end
          response = HTTParty.get("https://deckofcardsapi.com/api/deck/#{@deck_id}/draw/?count=1")
          card = response.parsed_response['cards'].first
          session[:hidden_cards] << card
          session[:hidden_cards] = session[:hidden_cards].shuffle
       elsif current_user.equipped.any? { |equipped_skill| equipped_skill.name == "天使の約束" }
          session[:hidden_cards] ||= []
          while session[:hidden_cards].length < 2
            response = HTTParty.get("https://deckofcardsapi.com/api/deck/#{@deck_id}/draw/?count=1")
            card = response.parsed_response['cards'].first
            if card_value(card) >= card_value(session[:visible_card])
              session[:hidden_cards] << card
            end
          end
          response = HTTParty.get("https://deckofcardsapi.com/api/deck/#{@deck_id}/draw/?count=2")
          cards = response.parsed_response['cards']
          session[:hidden_cards] += cards
          session[:hidden_cards] = session[:hidden_cards].shuffle
        else
          response = HTTParty.get("https://deckofcardsapi.com/api/deck/#{@deck_id}/draw/?count=4")
          session[:hidden_cards] = response.parsed_response['cards']
        end
      end
    end
  end

  def player_choice
    selected_card = params[:card_index] 
    @deck_id = session[:deck_id]
    redirect_to action: :reveal_card, card_index: selected_card
  end

  def reveal_card
    @selected_index = params[:card_index] .to_i
    if @selected_index.nil? || session[:hidden_cards].nil?
      flash[:danger] = '過去は変えられません。黒歴史がそうであるように…'
      redirect_to root_path
      return # ここで処理を終了する
    end
    @revealed_card = session[:hidden_cards][@selected_index]

    # 全てのカードを取得
    @hidden_cards = session[:hidden_cards]
    @visible_card = session[:visible_card]
    # 勝敗判定のロジックを使う
    @result = compare_cards(@revealed_card, session[:visible_card])

    bet_coin = session[:bet_coin]

    if bet_coin.nil?
      flash[:danger] = '過去は変えられません。黒歴史がそうであるように…'
      redirect_to root_path
    else
      case @result
      when "素晴らしい、おめでとうございます。"
        if current_user.equipped.any? { |equipped_skill| equipped_skill.name == "強欲の魔神" }
          current_user.coin += bet_coin * 3
        else
          current_user.coin += bet_coin * 2
        end
      when "同じ…あなたと私はどこか似ている。"
        current_user.coin += bet_coin
      end
      current_user.save
      session[:bet_coin] = nil
      render :result # result.html.erbに遷移
    end
  end

  def compare_cards(player_card, visible_card)
    player_value = card_value(player_card)
    visible_value = card_value(visible_card)

    if player_value > visible_value
      "素晴らしい、おめでとうございます。"
    elsif player_value < visible_value
      "残念、今回は私の勝ちです。"
    else
      "同じ…あなたと私はどこか似ている。"
    end
  end

  def card_value(card)
    case card['value']
    when 'KING'
      13
    when 'QUEEN'
      12
    when 'JACK'
      11
    when 'ACE'
      14
    else
      card['value'].to_i
    end
  end
end
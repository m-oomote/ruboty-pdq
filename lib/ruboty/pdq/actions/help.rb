module Ruboty
  module Pdq
    module Actions
      class Help < Ruboty::Actions::Base
        def call
          msg_str = "ruboty-pdqの使い方だよ☆\n"
          msg_str << "・pdq count <オプション>\nPDボールのPD問合せの件数を担当者ごとに表示するよ\n"
          msg_str << "<オプション>\nise : INSUITE関連のみ表示\nsdb : Sm@rtDB関連のみ表示\n\n"
          msg_str << "・pdq list <オプション>\nPDボールのPD問合せのうち一定期間動きがないものを表示するよ\n"
          msg_str << "<オプション>\n[整数] : 指定した日数以上経過したものだけを表示、デフォルトは3日\n\n"
          msg_str << "・pdq help\nヘルプを表示するよ"
          
          message.reply(msg_str, code: true)
        rescue => e
          message.reply(e.message)
        end # def call

      end
    end
  end
end

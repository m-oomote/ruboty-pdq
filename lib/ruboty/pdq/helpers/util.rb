module Ruboty
  module Pdq
    module Helpers
      class Util
        def initialize(message, channnel = nil)
          @message = message
          @channel = get_channel
          check_channel
        end

        def now
          Time.now.strftime("%Y/%m/%d %H:%M:%S.%L")
        end

        def get_channel
          @message.original[:from] ? @message.original[:from].split("@").first : "shell"
        end
        
        def check_channel
          if channels = ENV['RUBOTY_PDQ_CHANNELS']
            from_ch = get_channel
            raise "このチャンネルでは実行できないよ" if !channels.split(",").include?(from_ch)
          else
            raise "環境変数[RUBOTY_PDQ_CHANNELS]の設定が足りないみたい。。"
          end
        end

        # 呼び出し元ユーザ取得
        def get_caller
          puts "Ruboty::Ec2::Helpers::Util.get_caller called"
          @message.original[:from] ? @message.original[:from].split("/").last : "shell"
        end

        # 文字列の表示幅を求める.
        def print_size(string)
          string.each_char.map{|c| c.bytesize == 1 ? 1 : 2}.reduce(0, &:+)
        end

        # 指定された表示幅に合うようにパディングする.
        def pad_to_print_size(string, size)
          # パディングサイズを求める.
          padding_size = size - print_size(string)
          # string の表示幅が size より大きい場合はパディングサイズは 0 とする.
          padding_size = 0 if padding_size < 0

          # パディングする.
          string + ' ' * padding_size
        end
      end
    end
  end
end

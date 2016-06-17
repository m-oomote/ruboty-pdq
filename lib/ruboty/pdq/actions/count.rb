# -*- coding: utf-8 -*-
module Ruboty
  module Pdq
    module Actions
      class Count < Ruboty::Actions::Base
        # set env var
        SDB_URL       = ENV['RUBOTY_SDB_URL']
        LEADER_ISE    = ENV['RUBOTY_PDQ_LEADER_ISE'] || "DUMMY"
        LEADER_SDB    = ENV['RUBOTY_PDQ_LEADER_SDB'] || "DUMMY"
        TARGET_ISE    = ENV['RUBOTY_PDQ_TARGET_ISE'] || "DUMMY"
        TARGET_SDB    = ENV['RUBOTY_PDQ_TARGET_SDB'] || "DUMMY"
        
        def call
          puts "sdb count called"
          count
        end

        private

        def count
          # SDBアクセス、その他ユーティリティのインスタンス化
          sdb   = Ruboty::Pdq::Helpers::SmartDB.new(message)
          util  = Ruboty::Pdq::Helpers::Util.new(message)
          slack = Ruboty::Pdq::Helpers::Slack.new(message)
          
          leader_ise = LEADER_ISE.split(",")
          leader_sdb = LEADER_SDB.split(",")
          target_ise = TARGET_ISE.split(",")
          target_sdb = TARGET_SDB.split(",")
          
          cmd = message[:cmd] if !message[:cmd].nil?
          cmd = "all" if cmd.nil?

          # get total record count
          count_path  = "/hibiki/rest/1/binders/14979/views/10032/documents"
          url         = "#{SDB_URL}#{count_path}"
          resp_hash   = sdb.send_request(url)
          total_count = resp_hash[:totalCount].to_i if !resp_hash[:totalCount].nil?

          # get assign count
          assign_count = {}
          count        = 0
          page_size    = 10000
          max_page_num = (total_count/page_size.to_f).ceil
          (1..max_page_num).each do |num|
            url        = "#{SDB_URL}#{count_path}?pageSize=#{page_size}&pageNumber=#{num}"
            resp_hash  = sdb.send_request(url)
            resp_hash[:document].each do |qsn|
              assigned_member = []
              count_member = []
              target_product = ""
              status = ""
              qsn[:item].each do |item|
                if item[:id] == "10050" # Assigned Member
                  next if item[:value].nil?
                  member_ary = item[:value]
                  member_ary = [item[:value]] if !item[:value].is_a?(Array)
                  member_ary.each do |member|
                    member.each do |key, val|
                     next if key != :name
                      assigned_member.push(val)
                    end
                  end
                elsif item[:id] == "10054" # Status
                  next if item[:value].nil? or item[:value][:name].nil?
                  status = item[:value][:id]
                elsif item[:id] == "10107" # Product
                  next if item[:value].nil? or item[:value][:name].nil?
                  target_product = item[:value][:id]
                end
              end # qsn[:item].each do |item|
              next if cmd == "ise" and !target_ise.include?(target_product) 
              #ISE指定の場合対象がISEのもの以外はスキップ
              next if cmd == "sdb" and !target_sdb.include?(target_product) 
              #SDB指定の場合対象がSDBのもの以外はスキップ
              count = count + 1 
              if status == "23" # リーダー判断待ちなら対象製品のリーダーのボール
                if target_ise.include?(target_product) # 対象がISE
                  count_member = leader_ise
                elsif target_sdb.include?(target_product) # 対象がSDB
                  count_member = leader_sdb
                else # どちらにも属さない
                  count_member # どうすれば？
                end
              elsif status == "24" # 後もう一歩ならリーダーでないアサインメンバーのボール
                if target_ise.include?(target_product) # 対象がISE
                  count_member = assigned_member - leader_ise
                elsif target_sdb.include?(target_product) # 対象がSDB
                  count_member = assigned_member - leader_sdb
                else # どちらにも属さない
                  count_member = assigned_member # どうすれば？
                end
              else # それ以外の場合、アサインメンバー全員のボール
                count_member = assigned_member
              end # if
              count_member.each do |val|
                if assign_count.has_key?(val)
                  assign_count[val] += 1
                else
                  assign_count[val] = 1
                end
              end
            end # resp_hash[:document].each do |qsn|
          end # (1..max_page_num).each do |num|

          # make message
          msg_str     = "#{Time.now.strftime('%Y/%m/%d %H:%M')}時点のPD問合せ状況だよ\n"
          msg_str    << "INSUITE関連だけ表示しているよ\n" if cmd == "ise"
          msg_str    << "Sm@rtDB関連だけ表示しているよ\n" if cmd == "sdb"
          msg_str    << "現在 #{count}件だよ\n"
          msg_str    << "手持ち件数/名前の順に表示しているよ\n```"
          msg_str    << " 件数|   名前      \n"
          msg_str    << "-----+-------------\n"
          assign_count.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }.each do |name, count|
            msg_str       << sprintf("%4d | %s\n",
                             count, util.pad_to_print_size(name, 10))
            
          end
          msg_str << "```"
          # reply message
          slack.send_message(msg_str)
        rescue => e
          message.reply(e.message)
        end # def count
      end # class AssignCount < Ruboty::Actions::Base
    end # module Actions
  end # module Pdq
end # module Ruboty

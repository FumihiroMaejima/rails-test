class Masters::Information < ApplicationRecord
    self.primary_key = "id"
    self.table_name = 'informations' # フレームワーク側でテーブル名をよしなに変換してくれない為直接指定。
    self.inheritance_column = :_type_disabled # typeカラムはフレームワーク側で予約語になっている為エラーにならない様に設定が必要。
end

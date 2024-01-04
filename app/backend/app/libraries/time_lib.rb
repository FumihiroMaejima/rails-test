class TimeLib
    # クラスメソッドの定義
    class << self
        def date
            return Time.now
        end
    end

    # インスタンスメソッドの定義
    def instanceDate
        return Time.now
    end
end

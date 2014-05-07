require 'nkf'
require 'sinatra'
require 'dbi'
require 'sinatra/reloader'

get '/:hoge' do
  
  begin
    # SQL・プレースホルダーとも、Shift_JISにエンコード
    sql = to_sjis("SELECT Piyo From Hoge WHERE Fuga = ?")
    bind = to_sjis(params[:hoge].to_s)

    dbh = create_database_handle
    results = dbh.execute(sql, bind)

    @fuga = ""
    results.each { |r| @fuga += to_utf8(r[:Piyo]) }

    erb :index

  rescue Exception => e
    logger.error to_utf8(e.to_s)
  ensure
    dbh.disconnect if dbh
  end
end


def to_sjis(str)
  str ? NKF.nkf('-s', str) : ""
end


def to_utf8(str)
  str ? NKF.nkf('-w', str) : ""
end


def create_database_handle
  # プログラムでODBCの接続文字列を指定する場合
  # 上：ローカルドライブ、下：ネットワーク越しの書き方
  # dsn = %q(DBI:ODBC:Driver={Microsoft Access Driver (*.mdb, *.accdb)};Dbq=c://db/Sample.accdb;)
  dsn = %q(DBI:ODBC:Driver={Microsoft Access Driver (*.mdb, *.accdb)};Dbq=//127.0.0.1/db/Sample.accdb;)
  DBI.connect(dsn)

  # ODBCデータソースアドミニストレーターで設定してある場合
  # DBI.connect('DBI:ODBC:Sample')
end
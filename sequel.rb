require 'sinatra'
require 'sequel'
require 'sinatra/reloader'
require 'nkf'

ACCDB_PATH = '//127.0.0.1/db/Sample.accdb'

OLEDB_PROVIDER = 'Microsoft.ACE.OLEDB.12.0'
ODBC_DRIVER = '{Microsoft Access Driver (*.mdb, *.accdb)}'
DSN = 'SequelTest'




get '/not_found' do
  p 'not found'
end

get '/:type/:hoge' do
  redirect to('/not_found') unless %W(ado dsn dsnless).include?(params[:type])

  begin
    @type = params[:type]

    db = create_database_handle(@type)
    ds = db[:Hoge].where(:Fuga => :$n)

    hoge = to_placeholder(@type, params[:hoge])

    @fuga = ''
    ds.call(:all, :n => hoge).each do |row|
      piyo = select_piyo(@type, row)
      @fuga += to_utf8(piyo)
    end

    erb :index

  rescue Exception => e
    logger.error to_utf8(e.to_s)
  ensure
    db.disconnect
    puts "ConnectionCount(Before): #{Sequel::DATABASES.length}"
    Sequel::DATABASES.delete(db)
    puts "ConnectionCount(After): #{Sequel::DATABASES.length}"
  end
end


def to_placeholder(type='ado', hoge)
  type == 'ado' ? hoge : to_sjis(hoge)
end


def select_piyo(type='ado', row)
  type == 'ado' ? row[:Piyo] : row[:piyo]
end


def to_sjis(str)
  str ? NKF.nkf('-s', str) : ""
end

def to_utf8(str)
  str ? NKF.nkf('-w', str) : ""
end


def create_database_handle(connectionType='ado')
  case connectionType
  when 'ado'
    Sequel.ado(conn_string: "Provider=#{OLEDB_PROVIDER};Data Source=#{ACCDB_PATH}")
  when 'dsn'
    Sequel.odbc(DSN)
  when 'dsnless'
    p 'less'
    Sequel.odbc(drvconnect: "Driver=#{ODBC_DRIVER};Dbq=#{ACCDB_PATH};")
  end
end
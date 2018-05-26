(*
  Copyright 2016, MARS-Curiosity - REST Library

  Home: https://github.com/andrea-magni/MARS
*)
unit MARS.Linux.Daemon;

{$I MARS.inc}

{$IFDEF LINUX}

interface

uses
  Classes, SysUtils
, Posix.Stdlib, Posix.SysStat, Posix.SysTypes, Posix.Unistd, Posix.Signal, Posix.Fcntl
, IdHTTPWebBrokerBridge, IdSchedulerOfThreadPool, IdContext
;

const EXIT_CODE_SUCCESS = 0;
const EXIT_CODE_FAILURE = 1;

type
  TDummyIndyServer = class; // fwd

  TLinuxDaemon = class
  private
    FTerminated: Boolean;
  protected
    procedure DoLog(const AMsg: string); virtual;
    procedure DoError(const AMsg: string = ''; const AFatal: Boolean = True);
  protected
    procedure DoExecute; virtual;
  public
    constructor Create; virtual;
    procedure Start; virtual;
    procedure Terminate; virtual;

    property Terminated: Boolean read FTerminated;
  end;

  TMARSDaemon = class(TLinuxDaemon)
  private
    class var _Instance: TMARSDaemon;
  private
    FName: string;
  protected
    FServer: TIdHTTPWebBrokerBridge;
    FDummyIndy: TDummyIndyServer;
    FScheduler: TIdSchedulerOfThreadPool;

    procedure DoExecute; override;
    procedure DoLog(const AMsg: string); override;

    procedure SetupThreadScheduler;
    procedure StartServer; virtual;
    procedure StopServer; virtual;
    procedure IdleCycle;
  public
    constructor Create; override;
    procedure Start; override;
    procedure Log(const AMsg: string);

    property Name: string read FName write FName;

    class function Current: TMARSDaemon;
    class constructor ClassCreate;
  end;

  TDummyIndyServer = class
  public
    procedure ParseAuthenticationHandler(AContext: TIdContext;
      const AAuthType, AAuthData: String; var VUsername, VPassword: String;
      var VHandled: Boolean); virtual;
  end;

  procedure SignalsHandler(ASigNum: Integer); cdecl;

implementation

uses
  Types, StrUtils
, WebReq, WebBroker
, Server.Ignition, Server.WebModule
;

procedure SignalsHandler(ASigNum: Integer); cdecl;
begin
  case ASigNum of
    SIGTERM:
    begin
      TMARSDaemon.Current.Log('*** SIGTERM ***');
      TMARSDaemon.Current.Terminate;
    end;
    SIGHUP:
    begin
      TMARSDaemon.Current.Log('*** SIGHUP ***');
    end;
  end;
end;


{ TLinuxDaemon }

constructor TLinuxDaemon.Create;
begin
  inherited Create;
  FTerminated := False;
end;

procedure TLinuxDaemon.DoError(const AMsg: string; const AFatal: Boolean);
begin
  DoLog(AMsg);
  if AFatal then
    Halt(EXIT_CODE_FAILURE);
end;

procedure TLinuxDaemon.DoExecute;
begin

end;

procedure TLinuxDaemon.DoLog(const AMsg: string);
begin
  WriteLn(AMsg);
end;

procedure TLinuxDaemon.Start;
var
  Lpid, Lsid: pid_t;
  Lfid: Integer;
begin
  signal(SIGTERM, SignalsHandler);
  signal(SIGHUP, SignalsHandler);

  Lpid := fork();
  if Lpid < 0 then
    DoError('fork failed');
  if Lpid > 0  then
  begin
//      DoLog('fork done. Here is parent process. Will quit now.');
    Halt(0);
  end;
  if Lpid = 0 then
  begin
    DoLog('Forked process id ' + getpid.ToString);
    // INIT FILESYSTEM PERMISSION MODE
    umask(027);

    // ACQUIRE NEW SESSION ID
    Lsid := setsid;
    if Lsid < 0 then
      DoError('Unable to set sid');

    // CLOSE AND REROUTE STDIN/OUT/ERR
    __close(STDIN_FILENO);
    __close(STDOUT_FILENO);
    __close(STDERR_FILENO);

    Lfid := __open('/dev/null', O_RDWR);
    dup(Lfid); // STDOUT
    dup(Lfid); // STDERR

    // MOVE TO AN ALWAYS EXISTING DIRECTORY
    ChDir('/');

    // run actual daemon code
    DoExecute;

    halt(0);
  end;
end;

procedure TLinuxDaemon.Terminate;
begin
  FTerminated := True;
end;

{ TMARSDaemon }

class constructor TMARSDaemon.ClassCreate;
begin
  _Instance := nil;
end;

constructor TMARSDaemon.Create;
begin
  inherited Create;
  FName := 'MARSDaemon';
end;

class function TMARSDaemon.Current: TMARSDaemon;
begin
  if not Assigned(_Instance) then
    _Instance := TMARSDaemon.Create;
  Result := _Instance;
end;

procedure TMARSDaemon.DoExecute;
begin
  inherited;
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;

  FDummyIndy := TDummyIndyServer.Create;
  try
    FServer := TIdHTTPWebBrokerBridge.Create(nil);
    try
      FServer.OnParseAuthentication := FDummyIndy.ParseAuthenticationHandler;

//      SetupThreadScheduler;
      StartServer;

      IdleCycle;

    finally
      FServer.Free;
    end;
  finally
    FDummyIndy.Free;
  end;
end;

procedure TMARSDaemon.DoLog(const AMsg: string);
var
  LExeFileName, LLogFileName: string;
  LStreamWriter: TStreamWriter;
begin
//  inherited DoLog('[' + Name +'] ' + AMsg);

  LExeFileName := ParamStr(0);
  LLogFileName := ChangeFileExt(LExeFileName, '.log');

  LStreamWriter := TStreamWriter.Create(LLogFileName, True, TEncoding.UTF8);
  try
    LStreamWriter.Write(
      string.join('|', [DateTimeToStr(Now), Name, AMsg])
    );
    LStreamWriter.WriteLine;
  finally
    LStreamWriter.Free;
  end;
end;

procedure TMARSDaemon.IdleCycle;
begin
  while not Terminated do
  begin
    Log('Heartbeat');
    Sleep(5000);
  end;
end;

procedure TMARSDaemon.Log(const AMsg: string);
begin
  DoLog(AMsg);
end;

procedure TMARSDaemon.SetupThreadScheduler;
begin
  FScheduler := TIdSchedulerOfThreadPool.Create(FServer);
  try
    FScheduler.PoolSize := TServerEngine.Default.ThreadPoolSize;
    FServer.Scheduler := FScheduler;
    FServer.MaxConnections := FScheduler.PoolSize;
  except
    FServer.Scheduler.Free;
    FServer.Scheduler := nil;
    raise;
  end;
end;

procedure TMARSDaemon.Start;
begin
  Log('Starting...');
  inherited;
end;

procedure TMARSDaemon.StartServer;
begin
  FServer.DefaultPort := TServerEngine.Default.Port;
  FServer.Active := True;
end;

procedure TMARSDaemon.StopServer;
begin
  FServer.Active := False;
end;

{ TDummyIndyServer }

procedure TDummyIndyServer.ParseAuthenticationHandler(AContext: TIdContext;
  const AAuthType, AAuthData: String; var VUsername, VPassword: String;
  var VHandled: Boolean);
begin
  // Allow JWT Bearer authentication's scheme
  if SameText(AAuthType, 'Bearer') then
    VHandled := True;
end;

{$ENDIF}

end.

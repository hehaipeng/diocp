unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls, uIOCPHttpDecoder, uIOCPHttpEncoder, uHttpClientContext;

type
  TfrmMain = class(TForm)
    edtPort: TEdit;
    btnIOCPAPIRun: TButton;
    btnStopSevice: TButton;
    pnlINfo: TPanel;
    lblClientINfo: TLabel;
    lblRecvINfo: TLabel;
    lblSendINfo: TLabel;
    lblWorkCount: TLabel;
    lblMemINfo: TLabel;
    tmrTestINfo: TTimer;
    lblClientContextINfo: TLabel;
    chkHttpSvr: TCheckBox;
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnIOCPAPIRunClick(Sender: TObject);
    procedure btnStopSeviceClick(Sender: TObject);
    procedure tmrTestINfoTimer(Sender: TObject);
  private
    { Private declarations }
    FIOCPConsole: TIOCPConsole;
    FHttpDecoder:TIOCPHttpDecoder;
    FHttpEncoder:TIOCPHttpEncoder;
    FDecoder:TIOCPJSonStreamDecoder;
    FEncoder:TIOCPJSonStreamEncoder;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uIOCPCentre, uClientContext, TesterINfo, uBuffer, uMemPool;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDecoder := TIOCPJSonStreamDecoder.Create;
  FEncoder := TIOCPJSonStreamEncoder.Create;

  FHttpDecoder := TIOCPHttpDecoder.Create;
  FHttpEncoder := TIOCPHttpEncoder.Create;

  FIOCPConsole := TIOCPConsole.Create();

  //ע����չ�ͻ�����
  TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

  //ע�������
  TIOCPContextFactory.instance.registerDecoder(FDecoder);

  //ע�������
  TIOCPContextFactory.instance.registerEncoder(FEncoder);
end;

destructor TfrmMain.Destroy;
begin
  FIOCPConsole.close;
  FHttpDecoder.Free;
  FHttpEncoder.Free;
  FDecoder.Free;
  FEncoder.Free;
  FreeAndNil(FIOCPConsole);
  inherited Destroy;
end;

procedure TfrmMain.btnDiscountAllClientClick(Sender: TObject);
begin
  FIOCPConsole.DisconnectAllClientContext;
end;

procedure TfrmMain.btnIOCPAPIRunClick(Sender: TObject);
begin
  if not FIOCPConsole.Active then
  begin
    if chkHttpSvr.Checked then
    begin
      //ע����չ�ͻ�����
      TIOCPContextFactory.instance.registerClientContextClass(THttpClientContext);

      //ע�������
      TIOCPContextFactory.instance.registerDecoder(FHttpDecoder);

      //ע�������
      TIOCPContextFactory.instance.registerEncoder(FHttpEncoder);
    end else
    begin
      //ע����չ�ͻ�����
      TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

      //ע�������
      TIOCPContextFactory.instance.registerDecoder(FDecoder);

      //ע�������
      TIOCPContextFactory.instance.registerEncoder(FEncoder);
    end;

    //FIOCPConsole.WorkerCount := 1;
    FIOCPConsole.Port := StrToInt(edtPort.Text);
    FIOCPConsole.open;
    tmrTestINfo.Enabled := true;
  end;

  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;

end;

procedure TfrmMain.btnStopSeviceClick(Sender: TObject);
begin
  FIOCPConsole.close;
  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;
end;

procedure TfrmMain.tmrTestINfoTimer(Sender: TObject);
var
  lvCount, lvBusyCount:Integer;
begin
  lblClientINfo.Caption := '������:' + IntToStr(TesterINfo.__ClientContextCount);
  lblRecvINfo.Caption :=   '�������ݴ���:' + IntToStr(TesterINfo.__RecvTimes);
  lblSendINfo.Caption :=   '�������ݴ���:' + IntToStr(TesterINfo.__SendTimes);
  lblWorkCount.Caption :=  '�����߳�:' + IntToStr(FIOCPConsole.WorkerCount);
  lblMemINfo.Caption :=   Format(
     'IO�ڴ��ع�(%d),����(%d)',
     [TIODataMemPool.instance.getCount, TIODataMemPool.instance.getUseableCount]);

  lvCount := TIOCPContextFactory.instance.IOCPContextPool.count;
  lvBusyCount := TIOCPContextFactory.instance.IOCPContextPool.BusyCount;
  lblClientContextINfo.Caption :=   Format(
     'ClientContext�ع�(%d),����(%d)',
     [lvCount, lvCount - lvBusyCount]);
end;

end.
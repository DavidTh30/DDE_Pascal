//procedures
procedure subTest; far;
begin
end;

function fHandler: boolean; far;
begin
  fHandler:= true;
end;

//types
type
  PFarChar = ^char; far;  //HSZPAIR FAR *phszp;

//vars
var
  prcf: Procedure; far;

var
  p: procedure;

{$W no-near-far}  { Don't warn about the uselessness of `far' }

procedure Foo; far;  { `far' has no effect in GPC }
begin
  WriteLn ('Foo')
end;

begin
  p := Foo;  { Would also work without `far' in GPC. }
  p
end.

//{%H-} This suppresses all hints for that specific parameter
procedure MyProcedure(Sender: TObject; {%H-}Button: TMouseButton; {%H-}Shift: TShiftState);
begin
  // Sender is used, but Button and Shift are intentionally ignored
  Sender.Free;
end;

procedure MyProcedure(Sender: TObject; Button: TMouseButton);
begin
  {$push}
  {$warn 5024 off} // 5024 is the specific code for "Parameter not used"
  // Code here will not trigger the unused parameter hint
  {$pop}
end;

ByRef      var
Optional   const

C/C++ Type	        ObjectPascal Type
unsigned short [int]	Word
[signed] short [int]	SmallInt
unsigned [int]	        Cardinal { 3.25 fix }
[signed] int	        Integer
UINT	                LongInt { or Cardinal }
WORD	                Word
DWORD	                LongInt { or Cardinal }
unsigned long	        LongInt { or Cardinal }
unsigned long int	LongInt { or Cardinal }
[signed] long	        LongInt
[signed] long int	LongInt
char	                Char
signed char	        ShortInt
unsigned char	        Byte
char*	                PChar
LPSTR or PSTR	        PChar
LPWSTR or PWSTR	        PWideChar { 3.12 fix }
void*	                Pointer
BOOL	                Bool
float	                Single
double	                Double
long double      	Extended
///////////////////////////////////////////////////////////////
LP,NP,PP,P prefix: if first = T then T becomes P else P prefix
//////////////////////////////////////////////////////////////
HANDLE	                THandle
FARPROC	                TFarProc
ATOM	                TAtom
TPOINT	                TPoint
TRECT	                TRect
COLORREF	        TColorRef
OFSTRUCT	        TOFStruct
DEBUGHOOKINFO	        TDebugHookInfo
BITMAP	                TBitMap
RGBTRIPLE	        TRGBTriple
RGBQUAD	                 TRGBQuad
BITMAPCOREHEADER	TBitmapCoreHeader
BITMAPINFOHEADER	TBitmapInfoHeader
BITMAPINFO	        TBitmapInfo
BITMAPCOREINFO	        TBitmapCoreInfo
BITMAPFILEHEADER	TBitmapFileHeader
HANDLETABLE	        THandleTable
METARECORD	        TMetaRecord
METAHEADER	        TMetaHeader
METAFILEPICT	        TMetaFilePict
TEXTMETRIC	        TTextMetric
NEWTEXTMETRIC	        TNewTextMetric
LOGBRUSH	        TLogBrush
LOGPEN	                TLogPen
PATTERN	                TPattern { TLogBrush }
PALETTEENTRY	        TPaletteEntry
LOGPALETTE	        TLogPalette
LOGFONT	                TLogFont
ENUMLOGFONT	        TEnumLogFont
PANOSE	                TPanose
KERNINGPAIR	        TKerningPair
OUTLINETEXTMETRIC	TOutlineTextMetric
FIXED	                TFixed
MAT2	                TMat2
GLYPHMETRICS	        TGlyphMetrics
POINTFX	                TPointFX
TTPOLYCURVE	        TTTPolyCurve
TTPOLYGONHEADER	        TPolygonHeader
ABC	                TABC
RASTERIZER_STATUS	TRasterizer_Status
MOUSEHOOKSTRUCT	        TMouseHookStruct
CBTACTIVATESTRUCT	TCBTActivateStruct
HARDWAREHOOKSTRUCT	THardwareHookStruct
EVENTMSG	        TEventMsg
WNDCLASS	        TWndClass
MSG	                TMsg
MINMAXINFO	        TMinMaxInfo
SEGINFO	                TSegInfo
ACCEL	                TAccel
PAINTSTRUCT	        TPaintStruct
CREATESTRUCT	        TCreateStruct
CBT_CREATEWND	        TCBT_CreateWnd
MEASUREITEMSTRUCT	TMeasureItemStruct
DRAWITEMSTRUCT	        TDrawItemStruct
DELETEITEMSTRUCT	TDeleteItemStruct
COMPAREITEMSTRUCT	TCompareItemStruct
WINDOWPOS	        TWindowPos
WINDOWPLACEMENT	        TWindowPlacement
NCCALCSIZE_PARAMS	TNCCalcSize_Params
SIZE	                TSize
MENUITEMTEMPLATEHEADER	TMenuItemTemplateHeader
MENUITEMTEMPLATE	TMenuItemTemplate
DCB	                TDCB
COMSTAT	                TComStat
MDICREATESTRUCT	        TMDICreateStruct
CLIENTCREATESTRUCT	TClientCreateStruct
MULTIKEYHELP	        TMultiKeyHelp
HELPWININFO	        THelpWinInfo
CTLSTYLE	        TCtlStyle
CTLtype	                TCtltype
CTLINFO	                TCtlInfo
DDEADVISE	        TDDEAdvise
DDEDATA	                TDDEData
DDEPOKE	                TDDEPoke
DDEAACK	                TDDEAck
DEVMODE	                TDevMode
KANJISTRUCT	        TKanjiStruct

void **rgpvStoreProvFunc;
rgpvStoreProvFunc: PPointer;

CERT_STORE_PROV_INFO, *PCERT_STORE_PROV_INFO;
PCertStoreProvInfo = ^TCertStoreProvInfo;

typedef enum WING_DITHER_TYPE
 {
     WING_DISPERSED_4x4,
     WING_DISPERSED_8x8,
     WING_CLUSTERED_4x4
 } WING_DITHER_TYPE;
This is a so -called enumerated type, and can be translated into an ObjectPascal enumerated type very easily:
 type
   WING_DITHER_TYPE =
    (WING_DISPERSED_4x4,
     WING_DISPERSED_8x8,
     WING_CLUSTERED_4x4);


DAQUAL_AA_TEXT_ON               = 1L << 0,
DAQUAL_AA_TEXT_OFF              = 1L << 1,
DAQUAL_QUALITY_TRANSFORMS_ON    = 1L << 10,
DAQUAL_QUALITY_TRANSFORMS_OFF   = 1L << 11

DAQUAL_AA_TEXT_ON             = 1  shl 0,
DAQUAL_AA_TEXT_OFF            = 1  shl 1,
DAQUAL_QUALITY_TRANSFORMS_ON  = 1  shl 10,
DAQUAL_QUALITY_TRANSFORMS_OFF = 1  shl 11


#define GET_ALG_CLASS(x)                (x & (7 << 13))
#define GET_ALG_TYPE(x)                 (x & (15 << 9))
#define GET_ALG_SID(x)                  (x & (511))

unction GET_ALG_CLASS(x: DWORD): DWORD;
begin
  Result := (x and (7 shl 13));
end;

function GET_ALG_TYPE(x: DWORD): DWORD;
begin
  Result := (x and (15 shl 9));
end;

function GET_ALG_SID(x: DWORD): DWORD;
begin
  Result := (x and (511));
end;


#define ALG_CLASS_ANY                   (0)
#define ALG_CLASS_SIGNATURE             (1 << 13)
#define ALG_CLASS_MSG_ENCRYPT           (2 << 13)
#define ALG_CLASS_DATA_ENCRYPT          (3 << 13)

ALG_CLASS_ANY                       = (0);
ALG_CLASS_SIGNATURE                 = (1 shl 13);
ALG_CLASS_MSG_ENCRYPT               = (2 shl 13);
ALG_CLASS_DATA_ENCRYPT              = (3 shl 13);


#define INT_CONSTANT 42
#define FLOAT_CONSTANT1 3.14
#define FLOAT_CONSTANT2 .14
#define FLOAT_CONSTANT3 3.14f
#define STRING_CONSTANT "foo"
#define HEX_CONSTANT1 0x1234
#define HEX_CONSTANT2 0X4321
#define SHL_CONSTANT INT_CONSTANT<<2
#define SHR_CONSTANT 5>>2
#define COMPLEX_CONSTANT ((((INT_CONSTANT<<2)+INT_CONSTANT) | 0xFE) & 255)

const
  INT_CONSTANT = 43;
  FLOAT_CONSTANT1 = 3.14;
  FLOAT_CONSTANT2 = 0.14;
  FLOAT_CONSTANT3 = 3.14;
  STRING_CONSTANT = 'foo';
  HEX_CONSTANT1 = $1234;
  HEX_CONSTANT2 = $4321;
  SHL_CONSTANT = INT_CONSTANT shl 2;
  SHR_CONSTANT = 5 shr 2;
  COMPLEX_CONSTANT = ((((INT_CONSTANT shl 2)+INT_CONSTANT) or $FE) and 255);


  /// Struct with pointer alias of same name
struct Struct4 {
    int value;
} *PStruct4;

/// Typedef struct with alias of same name
typedef struct Struct5 {
    int value;
} Struct5;

 /// Struct with pointer alias of same name
  Struct4 = record
    value: Integer;
  end;

  /// Typedef struct with alias of same name
  Struct5 = record
    value: Integer;
  end;

type
  PStruct4 = ^Struct4;
  PStruct5 = ^Struct5;



/// Bit-backed struct3
  tag_Struct14 = record
  private
    Data0: Cardinal;
    function GetData0Value(const AIndex: Integer): Cardinal;
    procedure SetData0Value(const AIndex: Integer; const AValue: Cardinal);
  public
    property f1_1: Cardinal index $0A read GetData0Value write SetData0Value; // 10 bits at offset 0 in Data0
    property f1_2: Cardinal index $A01 read GetData0Value write SetData0Value; // 1 bits at offset 10 in Data0
    property f1_3: Cardinal index $B01 read GetData0Value write SetData0Value; // 1 bits at offset 11 in Data0
    property f1_4: Cardinal index $C01 read GetData0Value write SetData0Value; // 1 bits at offset 12 in Data0
    property f1_5: Cardinal index $D01 read GetData0Value write SetData0Value; // 1 bits at offset 13 in Data0
    property f1_6: Cardinal index $E01 read GetData0Value write SetData0Value; // 1 bits at offset 14 in Data0
    property f1_7: Cardinal index $F01 read GetData0Value write SetData0Value; // 1 bits at offset 15 in Data0
  var
    f2: Struct12;
    /// Bit-backed struct
    f3: Struct13;
  end;




  program asteriskDemo(input, output, stderr);

type
	day = (monday, tuesday, wednesday,
		thursday, friday, saturday, sunday);
var
	i: longint;
	n: real;
	m: set of day;
begin
	// multiplication operator
	i := 6 * 7;      // i becomes 42
	n := 6.0 * 7.0;  // n becomes 42.0

	// intersection operator
	m := [saturday, sunday] * [sunday, monday];
	// m is now {sunday}
end.



program exponentiation(input, output, stdErr);
// make operator overloading available
{$mode objFPC}
operator ** (const base: integer; const exponent: integer): integer;
begin
	if base <> 0 then
	begin
		result := trunc(exp(ln(base) * exponent));
	end;
end;
begin
	writeLn(2 ** 10); // will print 1024
end.




& denotes an octal base number.



decimal 38 (Hex $26)


Dec	Hex	Binary
0	$00	%00000000


{$typedAddress on}
program untypedAddressDemo(input, output, stderr);

procedure incrementIntByRef(const ref: PByte);
begin
	inc(ref^);
end;

var
	foo: integer;
begin
	foo := -1;
	incrementIntByRef(@foo);
	writeLn(foo);
end.

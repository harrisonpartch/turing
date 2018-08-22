MODULE TuringPll;
IMPORT Raster, Random, Objects, WMRectangles, WMGraphics, Modules, Strings,
	WM := WMWindowManager, Math, Out:=KernelLog, TT:=TuringTile;

CONST
	M = TT.M;
	TILEI=TT.TILEI;
	TILEJ=TT.TILEJ;
	TW=TT.TW;
	TH=TT.TH;
	T=TW*TH;
	MSIZE =TT.MSIZE;
	
TYPE Twindow* =  OBJECT(WM.BufferWindow)
VAR	
	alive, dead: BOOLEAN;
	i : LONGINT;
		
PROCEDURE KeyEvent (ucs : LONGINT; flags : SET; keysym : LONGINT);
BEGIN
	CASE CHR(ucs) OF
		| 'q': Close
	ELSE
	END
END KeyEvent;

PROCEDURE WheelMove(dz:LONGINT);
BEGIN
	gens:=SHORT(gens+dz);
	IF gens<1 THEN gens := 1 END;
	Out.Int(gens, 2);
	Out.Ln;
END WheelMove;

PROCEDURE &New*;
VAR 
	i, j : LONGINT;
BEGIN
	Init(M*MSIZE, M*MSIZE, FALSE);
	manager := WM.GetDefaultManager();
	manager.Add(100, 100, SELF, {WM.FlagFrame, WM.FlagClose, WM.FlagNoResizing});
	SetTitle(Strings.NewString("TuringPll Tutorial For Lac"));
	SetIcon(WMGraphics.LoadImage("WMIcons.tar://TuringCoatWnd.png", TRUE));
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			TT.mesh1[i, j] := 0;
			TT.mesh2[i, j] := 0;
			TT.n1[i, j] := 0
		END
	END;
	FOR i :=  2 TO M - 3 DO
		FOR j := 2 TO M - 3 DO
			IF random.Dice(100) > 98 THEN TT.mesh1[i, j] := random.Dice(1000)/1000 END
		END
	END;
END New;

PROCEDURE Draw*(canvas : WMGraphics.Canvas; w, h, q : LONGINT);
BEGIN
	Draw^(canvas, w, h, 0)
END Draw;

PROCEDURE Close;
BEGIN
	alive := FALSE;
	BEGIN {EXCLUSIVE} AWAIT(dead); END;
	Close^;
END Close;

PROCEDURE DrawIta;
VAR i, j, ix, jy : LONGINT;
	pix : Raster.Pixel;
	mode : Raster.Mode;
	r,g,blue: INTEGER;
BEGIN
	Raster.InitMode(mode, Raster.srcCopy);
	FOR i := 0 TO M - 1 DO
		ix := i * MSIZE;
		FOR j := 0 TO M - 1 DO
			jy := j * MSIZE;
			r:=SHORT(ENTIER(TT.mesh1[i, j] * 255) MOD 255);
			blue:= SHORT(ENTIER(TT.mesh2[i, j]*3500) MOD 255);
			Raster.SetRGB(pix,r,0,blue);
			Raster.Fill(img, ix, jy, ix+MSIZE, jy+MSIZE, pix, mode)
		END
	END;
	Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()))
END DrawIta;

PROCEDURE DrawItb;
VAR i, j, ix, jy : LONGINT;
	pix : Raster.Pixel;
	mode : Raster.Mode;
	r,g,blue: INTEGER;
BEGIN
	Raster.InitMode(mode, Raster.srcCopy);
	FOR i := 1 TO M -2 DO
		ix := i * MSIZE;
		FOR j := 1 TO M - 2 DO
			jy := j * MSIZE;
			r:=SHORT(ENTIER(TT.mesh1a[i, j] * 255) MOD 255);
			blue:= SHORT(ENTIER(TT.mesh2a[i, j] * 1357) MOD 255);
			Raster.SetRGB(pix,r,0,blue);
			Raster.Fill(img, ix, jy, ix+MSIZE, jy+MSIZE, pix, mode)
		END
	END;
	Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()))
END DrawItb;

PROCEDURE gotiles;
VAR
	i,j: INTEGER;
BEGIN	
	BEGIN {EXCLUSIVE} TT.tilesdone:=0 END; 
	FOR i:= 0 TO TW-1  DO
		FOR j:= 0 TO TH-1 DO
			tile[i,j].go;
		END
	END;	
(*     Out.String('xa'); 
	BEGIN {EXCLUSIVE} AWAIT(TT.tilesdone=T); END; 
	Objects.Sleep(1);*)
END gotiles;

BEGIN {ACTIVE}
	Objects.SetPriority(Objects.Normal);
	alive := TRUE;
	gens:=10;
	REPEAT
		FOR i:= 0 TO gens DO 
			gotiles
		END;
		DrawIta;
	UNTIL ~alive;
	TT.wdead:=TRUE;
	BEGIN {EXCLUSIVE} dead := TRUE; END;
END Twindow;

VAR
	tw: Twindow; 
	a,b,i,gens: INTEGER;
	random : Random.Generator;
	tile: ARRAY TW, TH OF TT.Tile;
	
PROCEDURE Open*;
BEGIN
	NEW(tw);
END Open;

PROCEDURE Close*;
BEGIN
	IF tw#NIL THEN tw.Close; tw:=NIL END;
END Close;

BEGIN
	Modules.InstallTermHandler(Close);
	NEW(random);
	FOR a:= 0 TO TW-1  DO
		FOR b:= 0 TO TH-1 DO
			NEW(tile[a,b], a*TILEI+1, b*TILEJ+1);
		END
	END;		
END TuringPll.

System.Free TuringPll ~

TuringPll.Open ~

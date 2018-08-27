MODULE TuringTile;
IMPORT Raster, Random, Objects, Strings,
	Math, Out:=KernelLog;


CONST
	M* =604;
	TILEI*=60;
	TILEJ*=60;
	TW*=10;
	TH*=10;
	T*=TW*TH;
	MSIZE* =1;


TYPE Tile*=OBJECT
VAR
	a,b: INTEGER;
	GO: BOOLEAN;
	
PROCEDURE&init*(i,j: INTEGER);
BEGIN
	a:= i;
	b:=j;
END init;

PROCEDURE go*;
BEGIN
	BEGIN{EXCLUSIVE}
     	GO:=TRUE
     END;
END go;

PROCEDURE stop;
BEGIN
	BEGIN{EXCLUSIVE}
     	GO:=FALSE
     END;
     inctiles;
END stop;

PROCEDURE inctiles;
BEGIN
	BEGIN{EXCLUSIVE}
     	INC(tilesdone) 
     END;
END inctiles;

PROCEDURE LNabes;
VAR i, j: LONGINT;
BEGIN
	BEGIN{EXCLUSIVE} AWAIT(GO) END;
	FOR i := a TO a+TILEI-1 DO
		FOR j := b TO b+TILEJ-1 DO
			gn[i, j] := g[i+1, j] + g[i-1, j] + g[i, j+1] + g[i, j-1]
			+ g[i+1, j-1] + g[i+1, j+1] + g[i-1, j-1] + g[i-1, j+1]	
		END
	END;
	stop;
END LNabes;

PROCEDURE LGeneration;
VAR i, j: LONGINT;
BEGIN
	BEGIN{EXCLUSIVE} AWAIT(GO) END;
	FOR i :=a TO a+TILEI-1 DO
		FOR j :=  b TO b+TILEJ-1 DO 
			IF gn[i,j]=2 THEN ng[i,j]:=1
			ELSIF gn[i,j]=3 THEN ng[i,j]:=1
			ELSE ng[i,j]:=0
			END
		END;
	END;
	stop;		
END LGeneration;

PROCEDURE Nabes;
VAR i, j: LONGINT;
BEGIN
	BEGIN{EXCLUSIVE} AWAIT(GO) END;
	FOR i := a TO a+TILEI-1 DO
		FOR j := b TO b+TILEJ-1 DO
			n1[i, j] := mesh1[i+1, j] + mesh1[i-1, j] + mesh1[i, j+1] + mesh1[i, j-1]
			+ mesh1[i+1, j-1] + mesh1[i+1, j+1] + mesh1[i-1, j-1] + mesh1[i-1, j+1]	
		END
	END;
	stop;
END Nabes;

PROCEDURE Generation;
VAR i, j: LONGINT;
BEGIN
	BEGIN{EXCLUSIVE} AWAIT(GO) END;
	FOR i :=a TO a+TILEI-1 DO
		FOR j :=  b TO b+TILEJ-1 DO 
			mesh1a[i, j] := ABS(mesh1[i, j] + n1[i, j]/143 - mesh2[i, j]);
			mesh2a[i, j] := ABS(mesh2[i, j] +  mesh1[i, j]/310 );   
			IF mesh1a[i, j]> 1 THEN mesh1a[i, j] := 0.5 END; 
		END;
	END;
	stop;		
END Generation;

PROCEDURE Nabesa;
VAR i, j: LONGINT;
BEGIN
	BEGIN{EXCLUSIVE} AWAIT(GO) END;
	FOR i := a TO a+TILEI-1 DO
		FOR j := b TO b+TILEJ-1 DO
			n1a[i, j] := mesh1a[i+1, j] + mesh1a[i-1, j] + mesh1a[i, j+1] + mesh1a[i, j-1]
			+ mesh1a[i+1, j-1] + mesh1a[i+1, j+1] + mesh1a[i-1, j-1] + mesh1a[i-1, j+1]	
		END
	END;
	stop;
END Nabesa;

PROCEDURE Generationa;
VAR i, j: LONGINT;
BEGIN
	BEGIN{EXCLUSIVE} AWAIT(GO) END;
	FOR i := a TO a+TILEI-1 DO
		FOR j := b TO b+TILEJ-1 DO
			mesh1[i, j] := ABS(mesh1a[i, j] + n1a[i, j]/73 - mesh2a[i, j]);
			mesh2[i, j] := ABS(mesh2a[i, j] +  mesh1a[i, j]/410);   
			IF mesh1[i, j]> 1 THEN mesh1[i, j] := 0.5 END;
		END;
	END;
	stop;
END Generationa;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)};
	REPEAT
		Nabes;
		Generation;
		LNabes;
		LGeneration;
		Nabesa;
		Generationa; 
	UNTIL wdead
END Tile;

VAR
	mesh1*, mesh2*, mesh1a*, mesh2a*,  n1*, n1a* : ARRAY M+2,M+2 OF REAL;
	g*,gn*,ng: ARRAY M+2,M+2 OF LONGINT;
     wdead*: BOOLEAN;
	a,b, tilesdone*: LONGINT;

END TuringTile.
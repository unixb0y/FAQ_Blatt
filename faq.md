# FAQ

## 1.1: Grundlagen von Bluespec System Verilog

* Ja, Es gibt Klassen & Typen.
  * Klassen werden in Bluespec Module genannt und können - ähnlich wie in Programmiersprachen - instanziiert werden und mit den erhaltenen Objekten gearbeitet werden.
  * Der Bluespec Compiler kann Typen prüfen (Typechecking) und somit sichergehen, dass konsistent gearbeitet wird und keine ungültigen Eingaben vorkommen.

* Ein Modul kann auf ein anderes zugreifen, indem es das instanziiert und an einen Bezeichner bindet, mit dem auf diese Instanz zugegriffen werden kann.

* Nein

* Methoden sind nach außen hin durch das Interface sichtbar. Funktionen können nur intern in Methoden und Rules verwendet werden und werden nicht im Interface definiert.

* In einem Interface müssen alle Methoden definiert werden.

* Regeln sind taktgebundene Abschnitte, die bei Erfüllen von deren CAN_FIRE und WILL_FIRE Bedingungen die enthaltenen Aktionen zur Taktflanke ausführen.

* Alle Zuweisungen in einer Regel geschehen gleichzeitig und parallel, Regeln zueinander sind - falls es die Präzedenzen erlauben - nebenläufig, feuern also im besten Fall im selben Takt. Falls das nicht möglich ist, laufen sie nacheinander in verschiedenen Takten ab. Regeln können nur feuern, wenn sowohl guard als auch der Body es erlauben.

* Semantik:
  * `HelloBluespec` -> definiert Namen des Packages
  * `mkHelloBluespec` -> definiert Namen des Moduls
  * `Empty` -> Kein Interface verwendet
  * `UInt#(32)` -> Typ des Registers
  * `flag` -> Name des Registers
  * `24` -> Wert, womit das Register initialisiert wird
  * `ActionValue#(Int#(8))` -> Rückgabetyp der Methode
  * `foo` -> Name der Methode
  * `int` -> Typ des Eingabeparameters der Methode
  * `x` -> Name des Eingabeparameters der Methode
* Syntax:
  * `package Paketname; endpackage`-> Anfang & Ende eines Pakets / Packages
  * `module ... (...); endmodule` -> Anfang & Ende eines Moduls
  * `Interface#(Typ) ... <- mkInterface(...);` -> Instanziierung eines Moduls
  * `method Typ Name (Parameterliste); endmethod` -> Anfang & Ende einer Methodenimplementierung

* Zuweisungsoperatoren:
  * `<=`: Zuweisung an Register / CRegs, Vergleich
  * `<-`: Zuweisung mit Action
  * `=`: Zuweisung ohne Action

* Ja, v.a. bei Testbenches üblich

* Vorteile:
  * Interface kann verschieden implementiert werden -> Verwendung für Nutzer "immer wie gewohnt", Black-Box Ansicht. Es gibt z.B. Standardinterfaces wie `Server`; wenn das eigene Modul dieses implementiert, weiß der Benutzer welche die Ein- und Ausgabemethoden sind ohne den Code einmal zu betrachten.
  * Implementierung eines Moduls kann ausgetauscht werden durch eine andere und der Rest funktioniert garantiert weiter, solange das neue Modul sich semantisch an das Interface hält
* Nachteile:
  * Änderung des Interfaces kann einiges kaputt machen
  * Testen von internen Methoden / Funktionen schwierig

* `int` entspricht `Int#(32)`, also einer 32-Bit Zahl mit Vorzeichen, `bit` entspricht einem 1-Bit Datenelement was nur 0 / 1 darstellen kann.

* Unterschied Wert- / Aktions- / Aktionswertmethoden:

|Wert|Aktion|Aktionswert|
|----|------|-----------|
|Liefert Wert zurück, kann keine Registerzuweisungen vornehmen|Kann Registerzuweisungen vornehmen, aber nicht in Register schreiben|Kann beides, aber der Rückgabewert ist ein ActionValue#(WertTyp) Typ, sodass man um an den Wert vom Typ WertTyp zu kommen den Zuweisungsoperator `<-` verwenden muss.|

* Guard

```
  rule compute(flag < 5); 
    ...
  endrule
```

```
  method calc(int c) if(flag < 5);
    ...
  endmethod
```

## 1.2: Weiterführende Elemente von Bluespec System Verilog

* numeric type: TODO

* Pipelines: TODO

* Parallel / Nebenläufig:
  * Parallel: Echt gleichzeitig, nur innerhalb einer rule möglich
  * Nebenläufig: Im gleichen Takt, aber nacheinander, in der Regel der Fall wenn mehrere rules in einem Takt feuern

* Wenn der guard wahr ist (CAN_FIRE), aber eine Bedingung im Body verletzt ist, die das Feuern unterbindet bzw. ein Konflikt besteht. Dann ist WILL_FIRE low und die Regel kann in dem Takt nicht ausgeführt werden.

* Beispielsweise wenn von einem Register gelesen werden soll, das im gleichen Takt von einer anderen Regel beschrieben wird.

* FIFOs:
  * Pipeline FIFO: fifo.enq bei voller FIFO möglich, falls gleichzeitig ein fifo.deq passiert.
  fifo.first liefert noch den alten Wert.

  * Bypass FIFO: fifo.deq bei leerer FIFO möglich, falls gleichzeitig ein fifo.enq passiert.
  fifo.first liefert bereits den neuen Wert.

  * Im Gegensatz dazu ist keins von beidem bei einer gewöhnlichen FIFO möglich. Weder `enqueue` bei voller FIFO und gleichzeitigem `dequeue`, noch `dequeue` bei leerer FIFO und gleichzeitigem `enqueue`.

* Wenn Konflikte auftreten, die ein nebenläufiges Feuern von Regeln verhindern, versucht er diese aufzulösen indem die Regeln in unterschiedlichen Takten nacheinander ausgeführt werden. Falls das aber Seiteneffekte hat und / oder willkürlich gewählt werden müsste und das Ergebnis von der Reihenfolge abhängt, werden Fehlermeldungen ausgegeben.

* nested interfaces: TODO

* `tagged union`s erlauben die Definition eines Typen, dessen tatsächliche Daten einen unterschiedlichen Typen haben. Beispielsweise kann man somit einen Datentyp MyNumber definieren, der je nach Anwendung entweder eine vorzeichenbehaftete oder eine nicht-vorzeichenbehaftete Zahl darstellen kann.

* Tupel:
  * Daten in Tupel fassen:  
  `let myTuple = tuple2(1,2);`, also die Funktion `tupleN` mit `N = Anzahl Elemente im Tupel, N <= 8` und der entsprechenden Anzahl an Parametern liefert das Tupel, was u.a. einer Variable zugewiesen werden kann wie im Beispiel.
  * Daten aus Tupel erhalten:  
  `let number1 = tpl_1(myTuple);`, also die Funktion `tpl_N`mit `N = Index, beginnend bei 1, maximal 8` liefert das indizierte Element.


* GALS: TODO

* `extend`: Datenbreite wird vergrößert, um in größeres Speicherelement / Variable zu passen
* `truncate`: Datenbreite wird verkleinert, um in ein kleineres Speicherelement / Variable zu passen

* pack: TODO

* unpack: TODO

* TODO

* Typklassen sind die Klassen von Typen

* CRegs

* Semantik:
  * `Int#(5)` -> Rückgabetyp und -breite
  * `add` -> Name der Funktion
  * `Int#(4) a, Int#(4) b` -> Eingabetypen, -breite, -namen
  * `extend` -> Funktion, die die Datenbreite erweitert
  * `+` -> Addition der 5-Bit Werte
  * `Int#(5)` -> Rückgabetyp und -breite
  * `addOne` -> Name der Methode
  * `Int#(4) delta` -> Eingabetyp, -breite, -name
  * `= add(1, delta)` -> Zuweisung des Ergebnisses der Funktion `add`, ausgeführt mit der `1, delta` als Parameter als Ergebnis der Methode `addOne`, also ist der Rückgabewert der Methode, die Erhöhung von `delta` um eins.
* Syntax:
  * `function Typ Name (Parameterliste); endfunction` -> Anfang & Ende einer Funktion
  * `method Typ Name (Parameterliste) = Function;` -> Inline Definition einer Methode als Zuweisung des Ergebnisses der Funktion.

* Urgency / Earliness:
  * Urgency: Welche `WILL_FIRE` Bedingungen zuerst ausgewertet werden; beeinflusst Entscheidung darüber, welche Regeln mit in die Menge genommen werden, die in einem bestimmten Takt ausgeführt wird.
  * Earliness: Bezeichnet, welche der im vorherigen Schritt "ausgewählten" Regeln dann im Endeffekt innerhalb des Taktes zuerst ausgeführt werden.

|descending_urgency|execution_order|                  preempts|
|------------------|---------------|--------------------------|
|           Urgency|      Earliness|TODO|

|mutually_exclusive|synthesize|
|------------------|----------|
|Wechselseitiger Ausschluss von Regeln|Kein Inlining bei Verilog-Übersetzung, sondern Beibehaltung von Modulhierachie in Form von Verilog-Modulen, die entsprechend über Parameter - wie in BSV - instantiiert werden. Ist nicht immer möglich, falls bspw. der Datentyp der Parameter nicht auf Verilog übertragbar ist.|

* Möglicherweise werden gar keine Ports generiert, falls die Methode inlined oder wegoptimiert wird.

* Durch `synthesize` wird vermieden, dass Module inlined werden und deren Input- und Output Ports werden "generiert".

## 1.3: Rund um FPGA

* 






















# FAQ

## 1.1: Grundlagen von Bluespec System Verilog

* Ja, Es gibt Klassen & Typen.
  * Klassen werden in Bluespec Module genannt und können - ähnlich wie in Programmiersprachen - instanziiert werden und mit den erhaltenen Objekten gearbeitet werden.
  * Der Bluespec Compiler kann Typen prüfen (Typechecking) und somit sichergehen, dass konsistent gearbeitet wird und keine ungültigen Eingaben vorkommen.

* Ein Modul kann auf ein anderes zugreifen, indem es das instanziiert und an einen Bezeichner bindet, mit dem auf diese Instanz zugegriffen werden kann.

* Nein, da Rekursionen nur in Software möglich sind, da sie einen Stack erfordern.

* Methoden sind nach außen hin durch das Interface sichtbar. Funktionen können nur intern in Methoden und Rules verwendet werden und werden nicht im Interface definiert.

* In einem Interface müssen alle Methoden definiert werden.

* Regeln sind taktgebundene Abschnitte, die bei Erfüllen von deren CAN_FIRE und WILL_FIRE Bedingungen die enthaltenen Aktionen zur Taktflanke ausführen.

* Alle Zuweisungen in einer Regel geschehen gleichzeitig und parallel, Regeln zueinander sind - falls es die Präzedenzen erlauben - nebenläufig, feuern also im besten Fall im selben Takt. Falls das nicht möglich ist, laufen sie nacheinander in verschiedenen Takten ab. Regeln können nur feuern, wenn sowohl Guard als auch der Body es erlauben.

* Semantik:
  * `HelloBluespec` -> definiert Namen des Packages
  * `mkHelloBluespec` -> definiert Namen des Moduls
  * `Empty` -> Kein Interface verwendet
  * `UInt#(32)` -> Typ des Registers
  * `flag` -> Name des Registers
  * `<-` -> Zuweisungsoperator
  * `maReg` -> Name des/eines Modules mit dem Inteface `Reg`
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
  * `<=`: Zuweisung an Register / CRegs / Vergleich
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

## 1.2: Weiterführende Elemente von Bluespec System Verilog

* numeric type: `fromInteger(valueOf(nums))`

* Pipelines:
  * statisch = Konstante Latenz von der Eingabe zur Ausgabe eines Datums, z.B. MIPS: immer 5 Takte für Fetch-Decode-Execute-Mem-Writeback
  * dynamisch = Latenz ist datenabhängig variabel
  * elastisch = Daten in unterschiedlichen Stufen schreiten mit unterschiedlichem Fortschritt durch Pipeline voran
  * starr = Daten schreiten überall mit gleichem Fortschritt durch Pipeline voran.
  Vgl. MIPS: alle Daten im Gleichschritt

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

* nested interfaces: Bei _nested interfaces_ / Unterschnittstellen, definiert das Interface eines Moduls wiederum Instanzen anderer Interfaces. Diese Instanzen / deren Methoden müssen dann vom Modul implementiert werden.

* `tagged union`s erlauben die Definition eines Typen, dessen tatsächliche Daten einen unterschiedlichen Typen haben. Beispielsweise kann man somit einen Datentyp MyNumber definieren, der je nach Anwendung entweder eine vorzeichenbehaftete oder eine nicht-vorzeichenbehaftete Zahl darstellen kann.

* Tupel:
  * Daten in Tupel fassen:  
  `let myTuple = tuple2(1,2);`, also die Funktion `tupleN` mit `N = Anzahl Elemente im Tupel, N <= 8` und der entsprechenden Anzahl an Parametern liefert das Tupel, was u.a. einer Variable zugewiesen werden kann wie im Beispiel.
  * Daten aus Tupel erhalten:  
  `let number1 = tpl_1(myTuple);`, also die Funktion `tpl_N`mit `N = Index, beginnend bei 1, maximal 8` liefert das indizierte Element.


* GALS bedeutet Globally asynchronous, locally synchronous

* `extend`: Datenbreite wird vergrößert, um in größeres Speicherelement / Variable zu passen
* `truncate`: Datenbreite wird verkleinert, um in ein kleineres Speicherelement / Variable zu passen

* pack: converts (packs) _from_ various types, including Bool,  Int, and UInt _to_ Bit.
* unpack: converts _from_ Bit _to_ various types, including Bool, Int, and UInt.

* Nein, pack und unpack ändern die Datenbreite nicht.

* Typklassen sind etwas wie Oberklassen, ein Typ ist dann eine Instanz einer Typklasse. Um einen Typ zu definieren, der z.B. von der Typklasse "Bits" erbt, kann man _deriving(Bits)_ verwenden.  
  * Vorgefertigte Typklassen:
    * Bits
    * Eq
    * Literal
    * RealLiteral
    * Arith
    * Ord
    * Bounded
    * Bitwise
    * BitReduction
    * BitExtend   

  * Dazugehörige Methoden:  
    * Bits: pack, unpack
    * BitExtend: zeroExtend, signExtend, truncate
    * Literal: fromInteger
    * RealLiteral: fromReal
    * numeric types: valueOf

* CRegs ermöglichen, im selben Takt zu schreiben und zu lesen (über verschiedene Ports).

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
|           Urgency|      Earliness|Wenn erste Regel feuern kann, tut sie das und verhindert das Feuern der zweiten Regel. Falls sie nicht feuern kann, behindert sie die zweite Regel nicht.|

|mutually_exclusive|synthesize|
|------------------|----------|
|Wechselseitiger Ausschluss von Regeln|Kein Inlining bei Verilog-Übersetzung, sondern Beibehaltung von Modulhierachie in Form von Verilog-Modulen, die entsprechend über Parameter - wie in BSV - instantiiert werden. Ist nicht immer möglich, falls bspw. der Datentyp der Parameter nicht auf Verilog übertragbar ist.|

* Möglicherweise werden gar keine Ports generiert, falls die Methode inlined oder wegoptimiert wird.

* Durch `synthesize` wird vermieden, dass Module inlined werden und deren Input- und Output Ports werden "generiert".

## 1.3: Rund um FPGA

* FPGAs ermöglichen die Entwicklung von Hardware-Schaltungen, die nach fertiger Entwicklung als ASICs hergestellt werden können, haben aber auch abgesehen von der ASIC-Entwicklung eigene Einsatzzwecke.  
Im Grunde sind sie für Anwendungen optimal, bei denen Hardwarebeschleuniger sinnvoll sind, ein eigener Chip sich aber nicht lohnt. Das kann daran liegen, dass die Funktion sich immer wieder ändert oder auch einfach, dass die Kosten für einen ASIC zu hoch sind.  
Sie sollten Desktoprechnern vorgezogen werden, wenn spezialisierte Berechnungen sehr schnell und mit hohem Durchsatz vorgenommen werden müssen.

* Liste:
  * Verhaltensebene
  * Systemebene 
  * RTL-Ebene
  * Logikebene
  * Transistorebene
  * Layoutebene

* Kosten, Geschwindigkeit, Fläche

* Längster Weg zwischen Registern / Pipeline Stufen. Direkter Einfluss auf die minimale Taktperiode / maximale Taktfrequenz.

* In BSV bestimmt die längste (da kombinatorische) Rechenoperation in einer Regel den kritischen Pfad, weil alle Berechnungen einer Regel immer innerhalb eines Taktes ablaufen.

* SoC: System-on-Chip; Alle Komponenten eines Systems auf einem Chip. Wesentliche Teile sind CPU, GPU, Speicher, Hardwarebeschleuniger, Controller(z.B. Audio, Display,...).

* NEON ist eine SIMD Architektur, die eine bestimmte Operation auf Daten, die einige Bits breit sind, parallel ausführt. (Vektorrechner/Vektorprozessor/Array-Prozessor)

* Cache-Kohärenz bedeutet, dass Speicherzugriffe nicht direkt an den Speicher gehen, sondern vorher in dem viel schnelleren Cache nach den Daten suchen. Wenn sie dort nicht vorhanden sind (Cache Miss), muss die gewöhnliche Anfrage an den Speicher gehen, wobei die angefragten Daten dann - für den nächsten Zugriff - im Cache abgelegt werden.  
Im Fall eines Cache Miss, dauert der Speicherzugriff somit länger, allerdings ist Cache-kohärenter Speicherzugriff bei einem Cache Hit um einiges schneller.  
Ein weiterer Nachteil tritt auf, wenn verschiedene Komponenten wie z.B. CPU und PL Cache-kohärent auf den Speicher zugreifen wollen und sich den Cache teilen. Dann könnte es sein, dass einer der beiden Teile des Caches überschreibt und der andere mehr Cache Misses erfährt als sonst. Ebenfalls muss der Cache immer aktuell gehalten werden, wenn z.B. Ein Beschleuniger in den L2 Cache schreibt müssen jene Variablen, die im L1 Cache abgebildet sind, in den L1 Cache übertragen werden.

* Es werden in der Regel keine Softcores benutzt, weil sie um einiges langsamer und größer sind als Hardcores.

* Die PL wird deshalb hauptsächlich für Hardware-Implementierungen von Algorithmen verwendet, bei denen dann teilweise durch massiv parallele Berechnungen an den passenden Stellen und fehlendem Overhead - da die Schaltung nur exakt das können muss was für den Algorithmus notwendig ist - sehr schnelle Ergebnisse geliefert werden können.

* AXI(4) ist ein Protokoll für Datenaustausch.

* ACP: Cache kohärent. HP: nicht Cache kohärent.

* Größe (Fläche, Komplexität), Adressierungsart, Burst Transfer

* Burst: Startadresse wird gesetzt und Datenmenge, woraufhin die gesamten Daten durch diese eine Anfrage geliefert werden.

* IP-Blöcke: Intellectual Properties / Hardware-Designs inklusive Tests und Dokumentation, die in der Regel gekauft werden und eine bestimmte Funktion erfüllen. Sie können dann als Black Box in der eigenen Schaltung verwendet werden und man muss nicht das Rad neu erfinden. Z.B.: Video Encoder.

* Signale außer in-/output : Reset (TODO?)

* Sortieren nach Performance (spezifische Anwendung):
  * ASIC
  * FPGA
  * GPGPU
  * Manycore CPU
  * Multicore CPU
  * LPCPU
  * SoC
  * microController
  * DSP

* Sortieren nach NRC (Hardwarekosten):
  * DSP
  * microController
  * SoC
  * LPCPU
  * FPGA, Multicore CPU
  * GPGPU
  * Manycore CPU
  * ASIC
  
* Sortieren nach Energieverbrauch:
  * GPGPU
  * Manycore CPU
  * Multicore CPU
  * FPGA
  * LPCPU
  * ASIC
  * SoC
  * microController
  * DSP

* Power Wall + Memory Wall + ILP Wall = Brick Wall
  * Power Wall: Mit steigendem Takt steigt die Stromaufnahme und damit die Wärmeabgabe, welche durch die Kühlung beschränkt ist.
  * Memory Wall: Speicherperformance entwickelt sich linear und nicht expotenziell, was nur mit Hilfe von Caches umgangen werden kann.
  * ILP Wall: Instruktionen können nicht mit unendlicher Paralellität ausgeführt werden, wird durch Abhängigkeien klassischer Computer beschränkt.

* LUTs, Block RAM, DSP tiles

* Base Design = leeres Design, spezifisch für ein bestimmtes Board, mit Standardverdrahtungen und entsprechenden Namen für Zugang zu Speicher, I/O usw. und wird regulär vom Boardhersteller mitgeliefert.

* Logic Design = Entwicklung und Test der eigentlichen Logik, die den Algorithmus ausführt.

* Hardware Synthesis = PNR (Place and Route) sowie Übertragung des Designs auf die Hardware und entsprechendes Testen.
  * Place = Operationen den Hardwareressourcen zuordnen
  * Route = Verdrahtung, Sicherstellen von Timing-Constraints

* AXI4 Interconnect IP: liefert AXI in-/output ports, kümmert sich um den Rest

* Was bedeutet spaltenorientiertes Design? 
Rekonfigurierbare Logikanteile durchzogen von Spalten von DSP/BRAM, so kann Logik einfach repliziert werden

* Wie wird beim TPC vorgegangen, um ein serielles Programm zu verarbeiten?
Computational Hotspots(kernels) identifizieren -> kernel code isolieren und nicht kritischen Code auf dem main Thread ausführen -> Hardware für jeden Thread replizieren 

* Was versteht man bei TPC unter Parallel Processing Element, Thread Unit, Thread Pool und Composition?
Parallel Processing Element: spalteorietiert, replizierte Hardware für jeden Kernel
Thread Unit: PEs für jeden Kernel 
Thread Pool: Abstraktion über Composition, besteht aus Thread Units
jobs kommen rein werden auf dem ersten freien PE ausgeführt, Antworten können out-of-order entgegengenommen werden
Composition: Größe der einzelnen Thread Units auf jedem Kernel 

* Wie spaltet der TPC das Design auf und welche Vorteile bringt das mit sich? 
In Architektur( organisiert Thread Units und PEs + Board/Plattform unabhängig) und Plattform(host-memory + hardware Abhängig), so können Hardware-Abhängige Teile auf die Plattform isoliert werden

* Um was kümmert sich ein AXI4 Interconnect IP? liefert Slave und Master Ports für die Kommunikation(bis zu 16 mit 16), wischen PEs und host

* Wie funktioniert die Kommunikation über ein Memory-Mapped AXI4Lite Control Register File?
Master spricht Slave über seine Adresse an, Crossbar Switch erstellt eine point-to-point connection zwischen den Beiden






















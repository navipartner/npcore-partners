codeunit 6014465 "String Library"
{
    // String Library.
    //  Work started by Nicolai Esbensen.
    //  Contributions manipulating _String are most welcome.
    //  Nonstring manipulating functions should be placed in another CU.
    //  Please do not refer to any other CU's, keep this codeunit atomic.
    //  Please maintain documentation when adding new functions.
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    // 
    //  "Construct(txtString : Text[1024])"
    //   Constructor. Assigns the internal string to the value of txtString
    // 
    //  "CountOccurences(Sequence : Text[10]) Occurences : Integer"
    //   Counts the number of times the Sequence is repeated in the string.
    // 
    //  "DeletePrefix(Text : Text[30])"
    //    If the text is a prefix of _String it's removed from the beginning of _String
    // 
    //  "DeleteSuffix(Text : Text[30])"
    //    If the text is a suffix of _String it's removed from the end of _String
    // 
    //  "EndsWith(Text : Text[30]) IsSuffix : Boolean" Added by Ren� Ravn
    //   Returns whether Text is a Suffix of _String or not
    // 
    //  "GetPrefixBySeq(Sequence : Text[10];n : Integer) Prefix : Text[512]"
    //   Returns the prefix by the n'th sequence. Returns the full string if n i larger than the number of sequences.
    // 
    //  "GetSentence("Sentence Length" : Integer) : Text[1024]"
    //   Returns the longest sentence (no words broken) shorter than "Sentence Length".
    // 
    //  "GetSuffixBySeq(Sequence : Text[10];n : Integer) Prefix : Text[512]"
    //   Returns the suffix by the n'th sequence. Returns the empty string if n i larger than the number of sequences.
    // 
    //  "Replace(_What : Text[30];_With : Text[30])"
    //   Replaces all occurences of _What with the value of _With
    // 
    //  "ReplaceSpecialChar()" Added by Ren� Ravn
    //   Replace all chars not in a-z & 0-9 & ,.-;: with '-'.
    //   Special convertion being �,�,�,� with a or A and �,�,�,� with o or O.
    // 
    //  "ReplaceWebChar()" Added by Ren� Ravn
    //   Replace all chars not in a-z & 0-9 with '-'.
    //   Special convertion being �,�,�,� with a or A and �,�,�,� with o or O.
    // 
    // 
    //  "SelectStringSep(Index : Integer;Sep : Text[1]) : Text[30]"
    //   Splits the string by the seperator Sep and returns the n'th string indicated by index.
    // 
    //  "SelectString(Index : Integer) : Text[250]"
    //   Splits the string using ',' as seperator and returns the n'th string indicated by index.
    // 
    //  "StartsWith(Text : Text[30]) IsPrefix : Boolean" Added by Ren� Ravn
    //   Returns whether Text is a Prefix of _String of not
    // 
    //  "Text() : Text[1024]"
    //   Accessor. Returns the current value of the internal string.
    // 
    //  "TrimStart(Sequence : Text[10])"
    //   Trims the start of the internal string for complete occurences of sequence
    // 
    //  "TrimEnd(Sequence : Text[10])"
    //   Trims the end of the internal string for complete occurences of sequence
    // 
    //  "TrimWhiteSpace(StringToTrim : Text[1024]) : Text[1024]"
    //   Returns the string with only texual representations
    // 
    // --------------------------------------------------------


    trigger OnRun()
    begin
    end;

    var
        _String: Text[1024];

    procedure Construct(txtString: Text[1024])
    begin
        _String := txtString;
    end;

    procedure CountOccurences(Sequence: Text[10]) Occurences: Integer
    var
        Index: Integer;
        String: Text[1024];
    begin
        Index := 1;
        String := _String;
        while (Index > 0) and (Occurences < 100) do begin
          Index  := StrPos(String,Sequence);
          if Index > 0 then begin
            Occurences += 1;
            String := CopyStr(String,Index+StrLen(Sequence));
          end;
        end;
    end;

    procedure DeletePrefix(Text: Text[30])
    begin
        if StartsWith(Text) then begin
          _String := CopyStr(_String,StrLen(Text)+1);
        end;
    end;

    procedure DeleteSuffix(Text: Text[30])
    begin
        if EndsWith(Text) then begin
          _String := CopyStr(_String,1,StrLen(_String) - StrLen(Text));
        end;
    end;

    procedure EndsWith(Text: Text[30]) IsSuffix: Boolean
    var
        SuffixLen: Integer;
        TextLen: Integer;
    begin
        SuffixLen := StrLen(Text);
        TextLen := StrLen(_String);

        exit(CopyStr(_String,TextLen - SuffixLen + 1) = Text);
    end;

    procedure GetPrefixBySeq(Sequence: Text[10];n: Integer) Prefix: Text[512]
    var
        Occurences: Integer;
        Suffix: Text[512];
        Index: Integer;
    begin
        if (CountOccurences(Sequence) < n) then
          exit(_String);
        Suffix := _String;
        Index := 1;
        while (n > 0) and (Index > 0) do begin
          Index := StrPos(Suffix,Sequence);
          if Index > 0 then begin
            n -= 1;
            Prefix += CopyStr(Suffix,1,Index);
            Suffix := CopyStr(Suffix,Index + 1);
           end;
        end;
        Prefix := CopyStr(Prefix,1,StrLen(Prefix)-1)
    end;

    procedure GetSentence("Sentence Length": Integer): Text[1024]
    var
        Index: Integer;
        LastSpace: Integer;
    begin
        for Index := 1 to "Sentence Length" do
          if _String[Index] = ' ' then LastSpace := Index;
        exit(CopyStr(_String,1,LastSpace));
    end;

    procedure GetSuffixBySeq(Sequence: Text[10];n: Integer) Suffix: Text[512]
    var
        Occurences: Integer;
        Prefix: Text[512];
        Index: Integer;
    begin
        if (CountOccurences(Sequence) < n) then
          exit('');
        Suffix := _String;
        Index := 1;
        while (n > 0) and (Index > 0) do begin
          Index := StrPos(Suffix,Sequence);
          if Index > 0 then begin
            n -= 1;
            Prefix += CopyStr(Suffix,1,Index);
            Suffix := CopyStr(Suffix,Index + 1);
           end;
        end;
    end;

    procedure Replace(_What: Text[30];_With: Text[30])
    var
        Index: Integer;
        Replacements: Integer;
    begin
        if _What = _With then exit;
        Index := 1;
        while (Index >= 0) and (Replacements < 100) do begin
          Replacements += 1;
          if (StrPos(CopyStr(_String,Index),_What) > 0) then
            Index     := StrPos(CopyStr(_String,Index),_What) + (Index-1)
          else Index := -1;
          if Index > 0 then begin
            _String := DelStr(_String,Index,StrLen(_What));
            _String := InsStr(_String,_With,Index);
            Index   += StrLen(_With);
          end;
        end;
    end;

    procedure ReplaceSpecialChar()
    var
        "String Length": Integer;
        Index: Integer;
    begin
        "String Length" := StrLen(_String) +1;
        Index := 1;
        while Index < "String Length" do begin
          case true of
            LowerCase(CopyStr(_String,Index,1)) in ['0','1','2','3','4','5','6','7','8','9',
                                                     'a','b','c','d','e','f','g','h','i','j',
                                                     'k','l','m','n','o','p','q','r','s','t',
                                                     'u','v','w','x','y','z',
                                                     '.',';',',',':','-'] :
              begin
                //continue to next index
              end;
            CopyStr(_String,Index,1) in ['�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'a',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'A',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'o',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'O',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�','�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'E',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�','�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'e',Index);
              end;
            else begin
              _String := DelStr(_String,Index,1);
              _String := InsStr(_String,'-',Index);
             end;
          end;
          Index +=1;
        end;
    end;

    procedure ReplaceWebSpecial()
    var
        "String Length": Integer;
        Index: Integer;
    begin
        "String Length" := StrLen(_String) +1;
        Index := 1;
        while Index < "String Length" do begin
          case true of
            LowerCase(CopyStr(_String,Index,1)) in ['0','1','2','3','4','5','6','7','8','9',
                                                     'a','b','c','d','e','f','g','h','i','j',
                                                     'k','l','m','n','o','p','q','r','s','t',
                                                     'u','v','w','x','y','z','-'] :
              begin
                //continue to next index
              end;
            CopyStr(_String,Index,1) in ['�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'a',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'A',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'o',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'O',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�','�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'E',Index);
              end;
            CopyStr(_String,Index,1) in ['�','�','�','�'] :
              begin
                _String := DelStr(_String,Index,1);
                _String := InsStr(_String,'e',Index);
              end;
            else begin
              _String := DelStr(_String,Index,1);
              _String := InsStr(_String,'-',Index);
             end;
          end;
          Index +=1;
        end;
    end;

    procedure SelectStringSep(Index: Integer;Sep: Text[10]): Text[250]
    var
        Int1: Integer;
        Int2: Integer;
        Itt: Integer;
        String: Text[1024];
    begin
        String := _String;
        Itt := 1;
        Int1:= 1;
        while Itt < Index do begin
          Int1   := StrPos(String,Sep) + StrLen(Sep);
          String := CopyStr(String,Int1);
          Itt += 1;
        end;
        Int2 := StrPos(String,Sep);
        if Int2 > 0 then
          exit(CopyStr(String,1,Int2-1))
        else
          exit(String);
    end;

    procedure SelectString(Index: Integer): Text[250]
    begin
        exit(SelectStringSep(Index,','));
    end;

    procedure StartsWith(Text: Text[30]) IsPrefix: Boolean
    var
        SuffixLen: Integer;
    begin
        SuffixLen := StrLen(Text);
        exit(CopyStr(_String,1,SuffixLen) = Text);
    end;

    procedure Text(): Text[1024]
    begin
        exit(_String)
    end;

    procedure TrimStart(Sequence: Text[10])
    var
        Index: Integer;
    begin
        while CopyStr(_String, 1, StrLen(Sequence)) = Sequence do
          _String := CopyStr(_String,1+StrLen(Sequence));
    end;

    procedure TrimEnd(Sequence: Text[10])
    begin
        while CopyStr(_String, StrLen(_String)-StrLen(Sequence)+1) = Sequence do
          _String := CopyStr(_String,1,StrLen(_String)-StrLen(Sequence));
    end;

    procedure TrimWhiteSpace(StringToTrim: Text[1024]): Text[1024]
    var
        Cr: Char;
        Lf: Char;
        Tab: Char;
    begin
        Tab := 9;
        Lf  := 10;
        Cr  := 13;
        exit(DelChr(StringToTrim, '=', Format(Tab) + Format(Lf) + Format(Cr) + ' '));
    end;

    procedure PadStrLeft(String: Text[60];TotalStrLen: Integer;PadChar: Text[30];After: Boolean) OutStr: Text[100]
    var
        i: Integer;
    begin
        OutStr:='';
        for i:=1 to TotalStrLen-StrLen(String) do begin
          if PadChar <> '' then
            OutStr:=OutStr + PadChar
          else OutStr:=OutStr + ' ';
        end;

        if After then
          OutStr := String + OutStr
        else
          OutStr := OutStr + String
    end;
}


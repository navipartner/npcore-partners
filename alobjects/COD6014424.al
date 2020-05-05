codeunit 6014424 Utility
{
    // //+NPR3.1t v.Simon Sch�bel d.20-10-05
    //    Funktion til at finde bonteksten
    // //+NPR3.1m d.14/09-2005 v.Simon
    //   Har lavet funktionen offFakturering der formaterer
    //   EAN, ref, att til fakturare og smidder dem i et 2D array
    //   med captions og v�rdien.
    // 
    // //NPR3.2g, NPK, DL, 05-01-07, Tilf�jet funktion CreateMailBarcode og CalcCheckNumber til stregkode for postlabel
    //                      05-03-07, Flyttet funktionalitet til Sales Shipment Header
    //                      05-03-07, CreateMailBarcode f�rdig implementeret
    // 
    // //NPR3.3, NPK, DL, 30-04-07, Tilf�jet funktion SendMailMergeDocumentViaSMTP
    // 
    // 
    // currSubstr:=0;
    // 
    // WHILE (currSubstr<substrno) DO BEGIN
    //   i := STRPOS(commastr, FORMAT(separator));
    //   substr:=COPYSTR(commastr,1,i-1);
    //   currSubstr+=1;
    //   commastr:=DELSTR(commastr,1, i);
    // END;
    // 
    // Param:
    // VarNameDataTypeSubtypeLength
    // NejsubstrnoInteger
    // NejcommastrText250
    // NejseparatorChar
    // 
    // Variable:
    // NameDataTypeSubtypeLength
    // iInteger
    // currSubstrInteger
    // 
    // Out:
    // substr text 250
    // 
    // //NPR4.000.001, NPK, MH, 21-01-09, Overf�rt funktion CreateMailBarcode til Cu 6014495 Package Label Management.
    // 
    // NPR4.12/TSA /20150703  CASE 216800 - Created W1 Version, adding wrappers on DK local fields in function offFakturering
    // NPR5.22/BHR /20160318  CASE 235061 Add check for EAN size
    // NPR5.23/MMV /20160610  CASE 244050 Removed deprecated CU reference in CreateCol()
    // NPR5.29/CLVA/20161122  CASE 252352 Added ftp functions: FTPUploadFile, FTPDownloadFile, FTPDeleteFile and FTPListFiles
    // NPR5.29/MMV /20161216  CASE 241549 Removed deprecated print/report code.
    // NPR5.29/TS  /20170105  CASE 262317 ItemNo. should not be a string when creating Alternative No.
    // NPR5.36/TJ  /20170919  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Removed unused functions
    // NPR5.48/RA  /20181219 CASE 337355 Changed FunctionVisibility of funtion GetTicketText to External
    // NPR5.54/BHR /20200219  CASE 389444 Ticket Text from POS Unit


    trigger OnRun()
    begin
    end;

    var
        AsciiStr: Text;
        AnsiStr: Text;
        TextAltNo: Label 'Item No.containing string is invalid for creating alternative no.';
        InternalVars: Boolean;

    procedure Ansi2Ascii(_Text: Text): Text
    begin
        //Ansi2Ascii
        if not InternalVars then
          MakeVars;
        exit(ConvertStr(_Text,AnsiStr,AsciiStr));
    end;

    procedure Ascii2Ansi(_Text: Text): Text
    begin
        //Ascii2Ansi
        if not InternalVars then
          MakeVars;
        exit(ConvertStr(_Text,AsciiStr,AnsiStr));
    end;

    procedure MakeVars()
    begin
        //MakeVars
        AsciiStr[1] := 128;
        AnsiStr[1] := 199;
        AsciiStr[2] := 129;
        AnsiStr[2] := 252;
        AsciiStr[3] := 130;
        AnsiStr[3] := 233;
        AsciiStr[4] := 131;
        AnsiStr[4] := 226;
        AsciiStr[5] := 132;
        AnsiStr[5] := 228;
        AsciiStr[6] := 133;
        AnsiStr[6] := 224;
        AsciiStr[7] := 134;
        AnsiStr[7] := 229;
        AsciiStr[8] := 135;
        AnsiStr[8] := 231;
        AsciiStr[9] := 136;
        AnsiStr[9] := 234;
        AsciiStr[10] := 137;
        AnsiStr[10] := 235;
        AsciiStr[11] := 138;
        AnsiStr[11] := 232;
        AsciiStr[12] := 139;
        AnsiStr[12] := 239;
        AsciiStr[13] := 140;
        AnsiStr[13] := 238;
        AsciiStr[14] := 141;
        AnsiStr[14] := 236;
        AsciiStr[15] := 142;
        AnsiStr[15] := 196;
        AsciiStr[16] := 143;
        AnsiStr[16] := 197;
        AsciiStr[17] := 144;
        AnsiStr[17] := 201;
        AsciiStr[18] := 145;
        AnsiStr[18] := 230;
        AsciiStr[19] := 146;
        AnsiStr[19] := 198;
        AsciiStr[20] := 147;
        AnsiStr[20] := 244;
        AsciiStr[21] := 148;
        AnsiStr[21] := 246;
        AsciiStr[22] := 149;
        AnsiStr[22] := 242;
        AsciiStr[23] := 150;
        AnsiStr[23] := 251;
        AsciiStr[24] := 151;
        AnsiStr[24] := 249;
        AsciiStr[25] := 152;
        AnsiStr[25] := 255;
        AsciiStr[26] := 153;
        AnsiStr[26] := 214;
        AsciiStr[27] := 154;
        AnsiStr[27] := 220;
        AsciiStr[28] := 155;
        AnsiStr[28] := 248;
        AsciiStr[29] := 156;
        AnsiStr[29] := 163;
        AsciiStr[30] := 157;
        AnsiStr[30] := 216;
        AsciiStr[31] := 158;
        AnsiStr[31] := 215;
        AsciiStr[32] := 159;
        AnsiStr[32] := 131;
        AsciiStr[33] := 160;
        AnsiStr[33] := 225;
        AsciiStr[34] := 161;
        AnsiStr[34] := 237;
        AsciiStr[35] := 162;
        AnsiStr[35] := 243;
        AsciiStr[36] := 163;
        AnsiStr[36] := 250;
        AsciiStr[37] := 164;
        AnsiStr[37] := 241;
        AsciiStr[38] := 165;
        AnsiStr[38] := 209;
        AsciiStr[39] := 166;
        AnsiStr[39] := 170;
        AsciiStr[40] := 167;
        AnsiStr[40] := 186;
        AsciiStr[41] := 168;
        AnsiStr[41] := 191;
        AsciiStr[42] := 169;
        AnsiStr[42] := 174;
        AsciiStr[43] := 170;
        AnsiStr[43] := 172;
        AsciiStr[44] := 171;
        AnsiStr[44] := 189;
        AsciiStr[45] := 172;
        AnsiStr[45] := 188;
        AsciiStr[46] := 173;
        AnsiStr[46] := 161;
        AsciiStr[47] := 174;
        AnsiStr[47] := 171;
        AsciiStr[48] := 175;
        AnsiStr[48] := 187;
        AsciiStr[49] := 181;
        AnsiStr[49] := 193;
        AsciiStr[50] := 182;
        AnsiStr[50] := 194;
        AsciiStr[51] := 183;
        AnsiStr[51] := 192;
        AsciiStr[52] := 184;
        AnsiStr[52] := 169;
        AsciiStr[53] := 189;
        AnsiStr[53] := 162;
        AsciiStr[54] := 190;
        AnsiStr[54] := 165;
        AsciiStr[55] := 198;
        AnsiStr[55] := 227;
        AsciiStr[56] := 199;
        AnsiStr[56] := 195;
        AsciiStr[57] := 207;
        AnsiStr[57] := 164;
        AsciiStr[58] := 208;
        AnsiStr[58] := 240;
        AsciiStr[59] := 209;
        AnsiStr[59] := 208;
        AsciiStr[60] := 210;
        AnsiStr[60] := 202;
        AsciiStr[61] := 211;
        AnsiStr[61] := 203;
        AsciiStr[62] := 212;
        AnsiStr[62] := 200;
        AsciiStr[63] := 214;
        AnsiStr[63] := 205;
        AsciiStr[64] := 215;
        AnsiStr[64] := 206;
        AsciiStr[65] := 216;
        AnsiStr[65] := 207;
        AsciiStr[66] := 221;
        AnsiStr[66] := 166;
        AsciiStr[67] := 222;
        AnsiStr[67] := 204;
        AsciiStr[68] := 224;
        AnsiStr[68] := 211;
        AsciiStr[69] := 225;
        AnsiStr[69] := 223;
        AsciiStr[70] := 226;
        AnsiStr[70] := 212;
        AsciiStr[71] := 227;
        AnsiStr[71] := 210;
        AsciiStr[72] := 228;
        AnsiStr[72] := 245;
        AsciiStr[73] := 229;
        AnsiStr[73] := 213;
        AsciiStr[74] := 230;
        AnsiStr[74] := 181;
        AsciiStr[75] := 231;
        AnsiStr[75] := 254;
        AsciiStr[76] := 232;
        AnsiStr[76] := 222;
        AsciiStr[77] := 233;
        AnsiStr[77] := 218;
        AsciiStr[78] := 234;
        AnsiStr[78] := 219;
        AsciiStr[79] := 235;
        AnsiStr[79] := 217;
        AsciiStr[80] := 236;
        AnsiStr[80] := 253;
        AsciiStr[81] := 237;
        AnsiStr[81] := 221;
        AsciiStr[82] := 238;
        AnsiStr[82] := 175;
        AsciiStr[83] := 239;
        AnsiStr[83] := 180;
        AsciiStr[84] := 240;
        AnsiStr[84] := 173;
        AsciiStr[85] := 241;
        AnsiStr[85] := 177;
        AsciiStr[86] := 243;
        AnsiStr[86] := 190;
        AsciiStr[87] := 244;
        AnsiStr[87] := 182;
        AsciiStr[88] := 245;
        AnsiStr[88] := 167;
        AsciiStr[89] := 246;
        AnsiStr[89] := 247;
        AsciiStr[90] := 247;
        AnsiStr[90] := 184;
        AsciiStr[91] := 248;
        AnsiStr[91] := 176;
        AsciiStr[92] := 249;
        AnsiStr[92] := 168;
        AsciiStr[93] := 250;
        AnsiStr[93] := 183;
        AsciiStr[94] := 251;
        AnsiStr[94] := 185;
        AsciiStr[95] := 252;
        AnsiStr[95] := 179;
        AsciiStr[96] := 253;
        AnsiStr[96] := 178;
        AsciiStr[97] := 255;
        AnsiStr[97] := 160;
        InternalVars := true;
    end;

    procedure CreateEAN(Unique: Code[25];Prefix: Code[2]) EAN: Code[20]
    var
        ErrEAN: Label 'Check No. is invalid for EAN-No.';
        ErrLength: Label 'EAN Creation number is too long.';
        Register: Record Register;
        RetailSetup: Record "Retail Setup";
        RetailFormCode: Codeunit "Retail Form Code";
        EAN1: Code[20];
    begin
        //CreateEAN
        //-NPR5.22
        if StrLen(Prefix) + StrLen(Register."Shop id") + StrLen(Format(Unique)) > 12 then
          Error(ErrLength);
        //+NPR5.22
        RetailSetup.Get;

        if Register.Get(RetailFormCode.FetchRegisterNumber) then;
        //-NPR5.29
        TestifString(Format(Unique));
        //+NPR5.29

        if StrLen(Unique) <= 10 then begin
          case Prefix of
            '':
              begin
                Prefix := Format(RetailSetup."EAN-Internal");
                EAN1 := PadStr('',10 - StrLen(Format(Unique)),'0');
                EAN := Format(Prefix) + PadStr('',10 - StrLen(Format(Unique)),'0') + Format(Unique);
              end;
            else
              begin
                EAN := Format(Prefix) + Format(Register."Shop id") +
                       PadStr('',12 - StrLen(Prefix) - (StrLen(Register."Shop id") + StrLen(Format(Unique))),'0') + Format(Unique);
              end;
          end;
          EAN := EAN + Format(StrCheckSum(EAN,'131313131313'));

          if StrCheckSum(EAN,'1313131313131') <> 0 then
            Error(ErrEAN);
        end else
          Error(ErrLength);
    end;

    procedure FormatDec2Text(Dec1: Decimal;nDec: Integer): Text[30]
    var
        decp: Text[3];
    begin
        //formatDec2Text
        if nDec = 0 then
          exit(Format(Round(Dec1,1)));

        decp := Format(nDec + 1);
        exit(Format(Round(Dec1,1 / Power(10,nDec)),0,'<sign><Integer><Decimal,' + decp + '>'));
    end;

    procedure FormatDec2Dec(Dec1: Decimal;nDec: Integer) Ret: Decimal
    var
        decp: Text[3];
    begin
        //formatDecimal
        if nDec = 0 then
          exit(Round(Dec1,1));

        decp := Format(nDec + 1);
        Evaluate(Ret,Format(Round(Dec1,1 / Power(10,nDec)),0,'<sign><Integer><Decimal,' + decp + '>'));
    end;

    [Scope('Personalization')]
    procedure GetTicketText(var RetailComment: Record "Retail Comment" temporary;Register: Record Register)
    var
        RetailComment2: Record "Retail Comment";
        RetailSetup2: Record "Retail Setup";
    begin
        //getTicketText
        //MESSAGE('Source: '+FORMAT(kasse."Sales Ticket Line Text off"));
        RetailComment.DeleteAll;
        case Register."Sales Ticket Line Text off" of
          Register."Sales Ticket Line Text off"::Comment:
            begin
              RetailComment2.SetRange("Table ID",6014401);
              RetailComment2.SetRange("No.",Register."Register No.");
              RetailComment2.SetRange(Integer,300);
              RetailComment2.SetRange("Hide on printout",false);
              if RetailComment2.Find('-') then begin
                repeat
                  // INSERT
                  RetailComment.Init;
                  RetailComment := RetailComment2;
                  RetailComment.Insert;
                until (RetailComment2.Next = 0);
              end;
            end;
          Register."Sales Ticket Line Text off"::"NP Config":
            begin
              if RetailSetup2.Get then;
              if RetailSetup2."Sales Ticket Line Text1" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := RetailSetup2."Sales Ticket Line Text1";
                RetailComment."Line No." := 1000;
                RetailComment.Insert;
              end;
              if RetailSetup2."Sales Ticket Line Text2" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := RetailSetup2."Sales Ticket Line Text2";
                RetailComment."Line No." := 2000;
                RetailComment.Insert;
              end;
              if RetailSetup2."Sales Ticket Line Text3" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := RetailSetup2."Sales Ticket Line Text3";
                RetailComment."Line No." := 3000;
                RetailComment.Insert;
              end;
              if RetailSetup2."Sales Ticket Line Text4" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := RetailSetup2."Sales Ticket Line Text4";
                RetailComment."Line No." := 4000;
                RetailComment.Insert;
              end;
              if RetailSetup2."Sales Ticket Line Text5" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := RetailSetup2."Sales Ticket Line Text5";
                RetailComment."Line No." := 5000;
                RetailComment.Insert;
              end;
              if RetailSetup2."Sales Ticket Line Text6" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := RetailSetup2."Sales Ticket Line Text6";
                RetailComment."Line No." := 6000;
                RetailComment.Insert;
              end;
              if RetailSetup2."Sales Ticket Line Text7" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := RetailSetup2."Sales Ticket Line Text7";
                RetailComment."Line No." := 7000;
                RetailComment.Insert;
              end;
            end;
          Register."Sales Ticket Line Text off"::Register:
            begin
              if Register."Sales Ticket Line Text1" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text1";
                RetailComment."Line No." := 1000;
                RetailComment.Insert;
              end;
              if Register."Sales Ticket Line Text2" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text2";
                RetailComment."Line No." := 2000;
                RetailComment.Insert;
              end;
              if Register."Sales Ticket Line Text3" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text3";
                RetailComment."Line No." := 3000;
                RetailComment.Insert;
              end;
              if Register."Sales Ticket Line Text4" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text4";
                RetailComment."Line No." := 4000;
                RetailComment.Insert;
              end;
              if Register."Sales Ticket Line Text5" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text5";
                RetailComment."Line No." := 5000;
                RetailComment.Insert;
              end;
              if Register."Sales Ticket Line Text6" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text6";
                RetailComment."Line No." := 6000;
                RetailComment.Insert;
              end;
              if Register."Sales Ticket Line Text7" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text7";
                RetailComment."Line No." := 7000;
                RetailComment.Insert;
              end;
              if Register."Sales Ticket Line Text8" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text8";
                RetailComment."Line No." := 8000;
                RetailComment.Insert;
              end;
              if Register."Sales Ticket Line Text9" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := Register."Sales Ticket Line Text9";
                RetailComment."Line No." := 9000;
                RetailComment.Insert;
              end;
            end;
        end;
    end;

    procedure Sign(Dec1: Decimal): Integer
    begin
        //sign
        if Dec1 >= 0 then
          exit(1)
        else
          exit(-1);
    end;

    procedure ReportVersion(ObjectID: Text[250]) ret: Text[250]
    var
        "Object": Record "Object";
    begin
        //ObjectVersion
        Object.SetRange(Type,Object.Type::Report);
        Object.SetRange(Name,CopyStr(ObjectID,StrPos(ObjectID,' ') + 1));
        if Object.Find('-') then
          ret := Format(Object.ID) + ' ' + Object."Version List";
    end;

    procedure GregorianDate2JulianDayNo(Date: Date): Integer
    var
        Days: Integer;
        i: Integer;
        m: Integer;
        Months: array [24] of Integer;
    begin
        Months[1] := 31;
        Months[2] := 28;
        if (Date2DMY(Date,3) mod 4 = 0) then begin
          if not (Date2DMY(Date,3) mod 100 = 0) then
            Months[2] := 29
          else if (Date2DMY(Date,3) mod 400 = 0) then
            Months[2] := 29;
        end;
        Months[3] := 31;
        Months[4] := 30;
        Months[5] := 31;
        Months[6] := 30;
        Months[7] := 31;
        Months[8] := 31;
        Months[9] := 30;
        Months[10] := 31;
        Months[11] := 30;
        Months[12] := 31;

        m := Date2DMY(Date,2);
        for i := 1 to m - 1 do begin
          Days += Months[i];
        end;

        Days += Date2DMY(Date,1);
        exit(Days);
    end;

    local procedure TestifString(InputTxt: Text)
    var
        Pos: Integer;
        IsString: Boolean;
    begin
        //-NPR5.29
        Pos := 1;
        InputTxt := LowerCase(InputTxt);
        while (Pos <= StrLen(InputTxt)) do begin
          IsString := InputTxt[Pos] in ['a','b','c','d','e','f','g','h','i','j',
                                        'k','l','m','n','o','p','q','r','s','t',
                                        'u','v','w','x','y','z'];
          if IsString then
            Error(TextAltNo);
          Pos += 1;
        end;
        //+NPR5.29
    end;

    procedure GetPOSUnitTicketText(var RetailComment: Record "Retail Comment" temporary;POSUnit: Record "POS Unit")
    var
        RetailComment2: Record "Retail Comment";
        RetailSetup2: Record "Retail Setup";
        POSUnitReceiptTextProfile: Record "POS Unit Receipt Text Profile";
    begin
        //+NPR5.54 [389444]
        //getPOSUnitTicketText
        if not POSUnitReceiptTextProfile.Get(POSUnit."POS Unit Receipt Text Profile") then
          exit;
        RetailComment.DeleteAll;
        case POSUnitReceiptTextProfile."Sales Ticket Line Text off" of
          POSUnitReceiptTextProfile."Sales Ticket Line Text off"::Comment:
            begin
              RetailComment2.SetRange("Table ID",DATABASE::"POS Unit");
              RetailComment2.SetRange("No.",POSUnit."POS Unit Receipt Text Profile");
              RetailComment2.SetRange(Integer,1000);
              RetailComment2.SetRange("Hide on printout",false);
              if RetailComment2.FindSet then begin
                repeat
                  RetailComment.Init;
                  RetailComment := RetailComment2;
                  RetailComment.Insert;
                until (RetailComment2.Next = 0);
              end;
            end;

          POSUnitReceiptTextProfile."Sales Ticket Line Text off"::"Pos Unit":
            begin
              if POSUnitReceiptTextProfile."Sales Ticket Line Text1" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text1";
                RetailComment."Line No." := 1000;
                RetailComment.Insert;
              end;
              if POSUnitReceiptTextProfile."Sales Ticket Line Text2" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text2";
                RetailComment."Line No." := 2000;
                RetailComment.Insert;
              end;
              if POSUnitReceiptTextProfile."Sales Ticket Line Text3" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text3";
                RetailComment."Line No." := 3000;
                RetailComment.Insert;
              end;
              if POSUnitReceiptTextProfile."Sales Ticket Line Text4" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text4";
                RetailComment."Line No." := 4000;
                RetailComment.Insert;
              end;
              if POSUnitReceiptTextProfile."Sales Ticket Line Text5" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text5";
                RetailComment."Line No." := 5000;
                RetailComment.Insert;
              end;
              if POSUnitReceiptTextProfile."Sales Ticket Line Text6" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text6";
                RetailComment."Line No." := 6000;
                RetailComment.Insert;
              end;
              if POSUnitReceiptTextProfile."Sales Ticket Line Text7" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text7";
                RetailComment."Line No." := 7000;
                RetailComment.Insert;
              end;
              if POSUnitReceiptTextProfile."Sales Ticket Line Text8" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text8";
                RetailComment."Line No." := 8000;
                RetailComment.Insert;
              end;
              if POSUnitReceiptTextProfile."Sales Ticket Line Text9" <> '' then begin
                RetailComment.Init;
                RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text9";
                RetailComment."Line No." := 9000;
                RetailComment.Insert;
              end;
            end;
        end;
        //+NPR5.54 [389444]
    end;
}


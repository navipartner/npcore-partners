codeunit 6014401 NPRDimensionManagement
{
    // NPR5.30/MHA /20170201  CASE 264918 Np Photo Module removed
    // NPR5.36/TJ  /20170920  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.55/TJ  /20200420  CASE 400524 Multi-Piece type should be mapped to Quantity Discount Header


    trigger OnRun()
    begin
    end;

    var
        TempDimBuf1: Record "Dimension Buffer" temporary;
        TempDimBuf2: Record "Dimension Buffer" temporary;
        TempDimBuf3: Record "Dimension Buffer" temporary;
        DimMgt: Codeunit DimensionManagement;
        HasGotGLSetup: Boolean;
        GLSetupShortcutDimCode: array [8] of Code[20];
        Text002: Label 'This Shortcut Dimension is not defined in the %1.';

    local procedure GetGLSetup()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        //GetGLSetup
        if not HasGotGLSetup then begin
          GLSetup.Get;
          GLSetupShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
          GLSetupShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
          GLSetupShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
          GLSetupShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
          GLSetupShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
          GLSetupShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
          GLSetupShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
          GLSetupShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";
          HasGotGLSetup := true;
        end;
    end;

    procedure UpdateNPRDefaultDim(TableID: Integer;RegisterNo: Code[10];SalesTicketNo: Code[20];Date2: Date;SaleType: Option;LineNo: Integer;No: Code[20];var GlobalDim1Code: Code[20];var GlobalDim2Code: Code[20])
    var
        NPRLineDimension: Record "NPR Line Dimension";
        RecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin
        //UpdateDocDefaultDim
        GetGLSetup;
        NPRLineDimension.SetRange("Table ID",TableID);
        NPRLineDimension.SetRange("Register No.",RegisterNo);
        NPRLineDimension.SetRange("Sales Ticket No.",SalesTicketNo);
        NPRLineDimension.SetRange(Date,Date2);
        NPRLineDimension.SetRange("Sale Type",SaleType);
        NPRLineDimension.SetRange("Line No.",LineNo);
        NPRLineDimension.SetRange("No.",No);
        NPRLineDimension.DeleteAll;
        GlobalDim1Code := '';
        GlobalDim2Code := '';
        if TempDimBuf2.Find('-') then begin
          repeat
            NPRLineDimension.Init;
            NPRLineDimension.Validate("Table ID",TableID);
            NPRLineDimension.Validate("Register No.",RegisterNo);
            NPRLineDimension.Validate("Sales Ticket No.",SalesTicketNo);
            NPRLineDimension.Validate(Date,Date2);
            NPRLineDimension.Validate("Sale Type",SaleType);
            NPRLineDimension.Validate("Line No.",LineNo);
            NPRLineDimension.Validate("No.",No);
            NPRLineDimension."Dimension Code" := TempDimBuf2."Dimension Code";
            NPRLineDimension."Dimension Value Code" := TempDimBuf2."Dimension Value Code";
            NPRLineDimension.Insert;
            RecRef.GetTable(NPRLineDimension);
            ChangeLogMgt.LogInsertion(RecRef);
            if NPRLineDimension."Dimension Code" = GLSetupShortcutDimCode[1] then
              GlobalDim1Code := NPRLineDimension."Dimension Value Code";
            if NPRLineDimension."Dimension Code" = GLSetupShortcutDimCode[2] then
              GlobalDim2Code := NPRLineDimension."Dimension Value Code";
          until TempDimBuf2.Next = 0;
          TempDimBuf2.Reset;
          TempDimBuf2.DeleteAll;
        end;
    end;

    procedure GetDefaultDim(TableID: array [10] of Integer;No: array [10] of Code[20];SourceCode: Code[20];var GlobalDim1Code: Code[20];var GlobalDim2Code: Code[20])
    var
        DefaultDimPriority1: Record "Default Dimension Priority";
        DefaultDimPriority2: Record "Default Dimension Priority";
        DefaultDim: Record "Default Dimension";
        i: Integer;
        j: Integer;
        NoFilter: array [2] of Code[20];
    begin
        //GetDefaultDim
        GetGLSetup;
        TempDimBuf2.Reset;
        TempDimBuf2.DeleteAll;
        if TempDimBuf1.Find('-') then begin
          repeat
            TempDimBuf2.Init;
            TempDimBuf2 := TempDimBuf1;
            TempDimBuf2.Insert;
          until TempDimBuf1.Next = 0;
        end;
        NoFilter[2] := '';
        for i := 1 to ArrayLen(TableID) do begin
          if (TableID[i] <> 0) and (No[i] <> '') then begin
            DefaultDim.SetRange("Table ID",TableID[i]);
            NoFilter[1] := No[i];
            for j := 1 to 2 do begin
              DefaultDim.SetRange("No.",NoFilter[j]);
              if DefaultDim.Find('-') then begin
                repeat
                  if (DefaultDim."Dimension Value Code" <> '') or
                     (DefaultDim."Value Posting" = DefaultDim."Value Posting"::"Code Mandatory")
                  then begin
                    TempDimBuf2.SetRange("Dimension Code",DefaultDim."Dimension Code");
                    if not TempDimBuf2.Find('-') then begin
                      TempDimBuf2.Init;
                      TempDimBuf2."Table ID" := DefaultDim."Table ID";
                      TempDimBuf2."Entry No." := 0;
                      TempDimBuf2."Dimension Code" := DefaultDim."Dimension Code";
                      TempDimBuf2."Dimension Value Code" := DefaultDim."Dimension Value Code";
                      TempDimBuf2.Insert;
                    end else begin
                      if (TempDimBuf2."Dimension Value Code" = '') and (DefaultDim."Dimension Value Code" <> '') then begin
                        TempDimBuf2."Dimension Value Code" := DefaultDim."Dimension Value Code";
                        TempDimBuf2.Modify;
                      end else
                        if DefaultDimPriority1.Get(SourceCode,DefaultDim."Table ID") then begin
                          if DefaultDimPriority2.Get(SourceCode,TempDimBuf2."Table ID") then begin
                            if DefaultDimPriority1.Priority < DefaultDimPriority2.Priority then begin
                              // npk/ohm - 231006
                              TempDimBuf3.Init;
                              TempDimBuf3 := TempDimBuf2;
                              TempDimBuf3."Table ID" := DefaultDim."Table ID";
                              TempDimBuf3."Entry No." := 0;
                              TempDimBuf3."Dimension Value Code" := DefaultDim."Dimension Value Code";
                              TempDimBuf3.Insert;
                              TempDimBuf2.Delete;
                              TempDimBuf2.Init;
                              TempDimBuf2 := TempDimBuf3;
                              TempDimBuf2.Insert;
                              TempDimBuf3.Delete;
                              //TempDimBuf2.RENAME(DefaultDim."Table ID",0,TempDimBuf2."Dimension Code");
                              //TempDimBuf2."Dimension Value Code" := DefaultDim."Dimension Value Code";
                              //TempDimBuf2.MODIFY;
                            end;
                          end else begin
                            // npk/ohm - 231006
                            TempDimBuf3.Init;
                            TempDimBuf3 := TempDimBuf2;
                            TempDimBuf3."Table ID" := DefaultDim."Table ID";
                            TempDimBuf3."Entry No." := 0;
                            TempDimBuf3."Dimension Value Code" := DefaultDim."Dimension Value Code";
                            TempDimBuf3.Insert;
                            TempDimBuf2.Delete;
                            TempDimBuf2.Init;
                            TempDimBuf2 := TempDimBuf3;
                            TempDimBuf2.Insert;
                            TempDimBuf3.Delete;
                            //TempDimBuf2.RENAME(DefaultDim."Table ID",0,TempDimBuf2."Dimension Code");
                            //TempDimBuf2."Dimension Value Code" := DefaultDim."Dimension Value Code";
                            //TempDimBuf2.MODIFY;
                          end;
                        end;
                    end;
                    if GLSetupShortcutDimCode[1] = TempDimBuf2."Dimension Code" then
                      GlobalDim1Code := TempDimBuf2."Dimension Value Code";
                    if GLSetupShortcutDimCode[2] = TempDimBuf2."Dimension Code" then
                      GlobalDim2Code := TempDimBuf2."Dimension Value Code";
                  end;
                until DefaultDim.Next = 0;
              end;
            end;
          end;
        end;
        TempDimBuf2.Reset;
    end;

    procedure TypeToTableNPR(Type: Option "G/L",Item,"Item Group",Repair,,Payment,"Open/Close",BOM,Customer,Comment): Integer
    begin
        //TypeToTableEksp
        case Type of
          Type::"G/L":
            exit(DATABASE::"G/L Account");
          Type::Item:
            exit(DATABASE::Item);
          Type::"Item Group":
            exit(DATABASE::"Item Group");
          Type::Repair:
            exit(DATABASE::"Customer Repair");
          //-NPR5.30 [264918]
          //Type::Fotoarbejde :
          //  EXIT(DATABASE::"Photo Work Main");
          //+NPR5.30 [264918]
          Type::Payment:
            exit(DATABASE::"Payment Type POS");
          Type::"Open/Close":
            exit(DATABASE::"Retail Comment");
          Type::BOM:
            exit(DATABASE::Item);
          Type::Customer:
            exit(DATABASE::Customer);
          Type::Comment:
            exit(DATABASE::"Retail Comment");
        end;
    end;

    procedure DiscountTypeToTableNPR(Type: Option " ",Period,Mix,"Multi-Piece","Sales Card",BOM,,Rounding,Combination,Customer): Integer
    begin
        //DiscountTypeToTableNPR
        case Type of
          Type::" " :
            exit(0);
          Type::Period:
            exit(DATABASE::"Period Discount");
          Type::Mix:
            exit(DATABASE::"Mixed Discount");
          Type::"Multi-Piece":
            //-NPR5.55 [400524]
            //EXIT(DATABASE::"Quantity Discount Line");
            exit(DATABASE::"Quantity Discount Header");
            //+NPR5.55 [400524]
          Type::"Sales Card":
            exit(0);
          Type::BOM:
            exit(0);
          //-NPR5.30 [264918]
          //Type::Fotoarbejde :
          //  EXIT(0);
          //+NPR5.30 [264918]
          Type::Rounding:
            exit(0);
          Type::Combination:
            exit(0);
          Type::Customer:
            exit(0);
        end;
    end;

    procedure DeleteNPRDim(TableID: Integer;RegisterNo: Code[10];SalesTicketNo: Code[20];Date2: Date;SaleType: Option;LineNo: Integer;No: Code[20])
    var
        NPRLineDimension: Record "NPR Line Dimension";
    begin
        //DeleteNPRDim
        NPRLineDimension.SetRange("Table ID",TableID);
        NPRLineDimension.SetRange("Register No.",RegisterNo);
        NPRLineDimension.SetRange("Sales Ticket No.",SalesTicketNo);
        NPRLineDimension.SetRange(Date,Date2);
        NPRLineDimension.SetRange("Sale Type",SaleType);
        NPRLineDimension.SetRange("Line No.",LineNo);
        NPRLineDimension.SetRange("No.",No);
        NPRLineDimension.DeleteAll;
    end;

    procedure LookupDimValueCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    var
        DimVal: Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
    begin
        //LookupDimValueCode
        GetGLSetup;
        if GLSetupShortcutDimCode[FieldNumber] = '' then
          Error(Text002,GLSetup.TableCaption);
        DimVal.SetRange("Dimension Code",GLSetupShortcutDimCode[FieldNumber]);
        DimVal."Dimension Code" := GLSetupShortcutDimCode[FieldNumber];
        DimVal.Code := ShortcutDimCode;
        if PAGE.RunModal(0,DimVal) = ACTION::LookupOK then begin
          DimMgt.CheckDim(DimVal."Dimension Code");
          DimMgt.CheckDimValue(DimVal."Dimension Code",DimVal.Code);
          ShortcutDimCode := DimVal.Code;
        end;
    end;

    procedure ValidateDimValueCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        //ValidateDimValueCode
        DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
    end;

    procedure SaveDefaultDim(TableID: Integer;No: Code[20];FieldNumber: Integer;ShortcutDimCode: Code[20])
    begin
        //SaveDefaultDim
        DimMgt.SaveDefaultDim(TableID,No,FieldNumber,ShortcutDimCode);
    end;

    procedure SaveNPRDim(TableID: Integer;RegisterNo: Code[10];SalesTicketNo: Code[20];Date2: Date;SaleType: Option;LineNo: Integer;No: Code[20];FieldNumber: Integer;ShortcutDimCode: Code[20])
    var
        NPRLineDim: Record "NPR Line Dimension";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin
        //SaveEkspDim
        GetGLSetup;
        if ShortcutDimCode <> '' then begin
          if NPRLineDim.Get(TableID,RegisterNo,SalesTicketNo,Date2,SaleType,LineNo,No,GLSetupShortcutDimCode[FieldNumber]) then begin
            xRecRef.GetTable(NPRLineDim);
            NPRLineDim.Validate("Dimension Value Code",ShortcutDimCode);
            NPRLineDim.Modify;
            /* This has been commented by NE, as it only updates
              From Sale POS to Lines which i not applicable if you
              want individual dimensions on lines.
              NPRLineDim.UpdateLineDim(NPRLineDim,FALSE);
            */
            RecRef.GetTable(NPRLineDim);
            ChangeLogMgt.LogModification(RecRef);
          end else begin
            NPRLineDim.Init;
            NPRLineDim.Validate("Table ID",TableID);
            NPRLineDim.Validate("Register No.",RegisterNo);
            NPRLineDim.Validate("Sales Ticket No.",SalesTicketNo);
            NPRLineDim.Validate(Date,Date2);
            NPRLineDim.Validate("Sale Type",SaleType);
            NPRLineDim.Validate("Line No.",LineNo);
            NPRLineDim.Validate("No.",No);
            NPRLineDim.Validate("Dimension Code",GLSetupShortcutDimCode[FieldNumber]);
            NPRLineDim.Validate("Dimension Value Code",ShortcutDimCode);
            NPRLineDim.Insert(true);
            NPRLineDim.UpdateLineDim(NPRLineDim,false);
            RecRef.GetTable(NPRLineDim);
            ChangeLogMgt.LogInsertion(RecRef);
          end;
        end else begin
          if NPRLineDim.Get(TableID,RegisterNo,SalesTicketNo,Date2,SaleType,LineNo,No,GLSetupShortcutDimCode[FieldNumber]) then begin
            xRecRef.GetTable(NPRLineDim);
            NPRLineDim."Dimension Value Code" := '';
            NPRLineDim.Modify;
            RecRef.GetTable(NPRLineDim);
            ChangeLogMgt.LogModification(RecRef);
            NPRLineDim.UpdateLineDim(NPRLineDim,true);
          end;
        end;

    end;

    procedure SaveTempDim(FieldNumber: Integer;ShortcutDimCode: Code[20])
    begin
        //SaveTempDim
        GetGLSetup;
        TempDimBuf2.SetRange("Dimension Code",GLSetupShortcutDimCode[FieldNumber]);
        if ShortcutDimCode <> '' then begin
          if TempDimBuf2.Find('-') then begin
            TempDimBuf2.Validate("Dimension Value Code",ShortcutDimCode);
            TempDimBuf2.Modify;
          end else begin
            TempDimBuf2.Init;
            TempDimBuf2.Validate("Table ID",0);
            TempDimBuf2.Validate("Entry No.",0);
            TempDimBuf2.Validate("Dimension Code",GLSetupShortcutDimCode[FieldNumber]);
            TempDimBuf2.Validate("Dimension Value Code",ShortcutDimCode);
            TempDimBuf2.Insert;
          end;
        end else if TempDimBuf2.Find('-') then begin
          TempDimBuf2."Dimension Value Code" := '';
          TempDimBuf2.Modify;
        end;
    end;

    procedure OpenFormDefaultDimensions(TableID: Integer;No: Code[20])
    begin
        //OpenFormDefaultDimensions
        /*
        DefaultDimension.SETRANGE("Table ID",TableID);
        DefaultDimension.SETRANGE("No.",No);
        DefaultDimensionsFrm.SETTABLEVIEW(DefaultDimension);
        DefaultDimensionsFrm.RUN;*/

    end;

    procedure CopyAuditRollDimToSaleLinePOSDim(var AuditRoll: Record "Audit Roll";var SaleLinePOS: Record "Sale Line POS")
    var
        FromNPRLineDim: Record "NPR Line Dimension";
        ToNPRLineDim: Record "NPR Line Dimension";
    begin
        //CopyRevRulleDimToEkspLineDim
        Clear(ToNPRLineDim);
        if SaleLinePOS."Line No." <> 0 then begin
          ToNPRLineDim.SetRange("Table ID",DATABASE::"Sale Line POS");
          ToNPRLineDim.SetRange("Register No.",SaleLinePOS."Register No.");
          ToNPRLineDim.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
          ToNPRLineDim.SetRange(Date,SaleLinePOS.Date);
          ToNPRLineDim.SetRange("Sale Type",SaleLinePOS."Sale Type");
          ToNPRLineDim.SetRange("Line No.",SaleLinePOS."Line No.");
          ToNPRLineDim.SetRange("No.",'');
          ToNPRLineDim.DeleteAll(true);
        end;

        Clear(ToNPRLineDim);
        with FromNPRLineDim do begin
          SetNPRDimFilterAuditRoll(FromNPRLineDim,AuditRoll);
          if Find('-') then
            repeat
              ToNPRLineDim."Table ID" := DATABASE::"Sale Line POS";
              ToNPRLineDim."Register No." := SaleLinePOS."Register No.";
              ToNPRLineDim."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
              ToNPRLineDim.Date := SaleLinePOS.Date;
              ToNPRLineDim."Sale Type" := SaleLinePOS."Sale Type";
              ToNPRLineDim."Line No." := SaleLinePOS."Line No.";
              ToNPRLineDim."No." := '';
              ToNPRLineDim."Dimension Code" := FromNPRLineDim."Dimension Code";
              ToNPRLineDim."Dimension Value Code" := FromNPRLineDim."Dimension Value Code";
              if not ToNPRLineDim.Insert(true) then
                ToNPRLineDim.Modify(true);
            until Next = 0;
        end;
    end;

    procedure SetNPRDimFilterSaleLinePOS(var NPRLineDimension: Record "NPR Line Dimension";var SaleLinePOS: Record "Sale Line POS")
    begin
        //SetNPRDimFilterEkspLine
        NPRLineDimension.SetRange("Table ID",DATABASE::"Sale Line POS");
        NPRLineDimension.SetRange("Register No.",SaleLinePOS."Register No.");
        NPRLineDimension.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");

        NPRLineDimension.SetRange(Date,SaleLinePOS.Date);  //ohm - 13/3/06
        //NPRDimension.SETRANGE(Date);
        NPRLineDimension.SetRange("Sale Type",SaleLinePOS."Sale Type");
        NPRLineDimension.SetRange("Line No.",SaleLinePOS."Line No.");
        //NPRDimension.SETRANGE("No.",'');
    end;

    procedure SetNPRDimFilterAuditRoll(var NPRLineDimension: Record "NPR Line Dimension";var AuditRoll: Record "Audit Roll")
    begin
        //SetNPRDimFilterRevRulle
        NPRLineDimension.SetRange("Table ID",DATABASE::"Audit Roll");
        NPRLineDimension.SetRange("Register No.",AuditRoll."Register No.");
        NPRLineDimension.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        NPRLineDimension.SetRange(Date,AuditRoll."Sale Date");
        NPRLineDimension.SetRange("Sale Type",AuditRoll."Sale Type");
        NPRLineDimension.SetRange("Line No.",AuditRoll."Line No.");
        NPRLineDimension.SetRange("No.",AuditRoll."No.");
    end;

    procedure CopySaleLineDimToAuditDim(var SaleLinePOS: Record "Sale Line POS";var AuditRoll: Record "Audit Roll")
    var
        FromNPRLineDim: Record "NPR Line Dimension";
        ToNPRLineDim: Record "NPR Line Dimension";
    begin
        //CopySaleLineDimToAuditDim()
        Clear(ToNPRLineDim);
        if AuditRoll."Sales Ticket No." <> '' then begin
          ToNPRLineDim.SetRange("Table ID",DATABASE::"Audit Roll");
          ToNPRLineDim.SetRange("Register No.",AuditRoll."Register No.");
          ToNPRLineDim.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
          ToNPRLineDim.SetRange(Date,AuditRoll."Sale Date");
          ToNPRLineDim.SetRange( "Sale Type", AuditRoll."Sale Type" );
          ToNPRLineDim.SetRange( "Line No.", AuditRoll."Line No." );
          ToNPRLineDim.SetRange( "No.", AuditRoll."No." );
          ToNPRLineDim.DeleteAll(true);
        end;

        Clear(ToNPRLineDim);
        with FromNPRLineDim do begin
          SetNPRDimFilterSaleLinePOS(FromNPRLineDim,SaleLinePOS);
          if Find('-') then repeat
            ToNPRLineDim."Table ID" := DATABASE::"Audit Roll";
            ToNPRLineDim."Register No." := SaleLinePOS."Register No.";
            ToNPRLineDim."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            ToNPRLineDim.Date := SaleLinePOS.Date;
            ToNPRLineDim."Sale Type" := AuditRoll."Sale Type";
            ToNPRLineDim."Line No." := AuditRoll."Line No.";
            ToNPRLineDim."No." := AuditRoll."No.";
            ToNPRLineDim."Dimension Code" := FromNPRLineDim."Dimension Code";
            ToNPRLineDim."Dimension Value Code" := FromNPRLineDim."Dimension Value Code";
            if not ToNPRLineDim.Insert(true) then
              ToNPRLineDim.Modify(true);
          until Next = 0;
        end;
    end;
}


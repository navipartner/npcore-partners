codeunit 6014592 "Change Log Settings"
{
    // NPR4.16/LS/20150907  CASE 222050 : Activate tables in Change log setup
    //                                    2 parameters required : Table Details e.g ID;Name and logging Type ('',Some,All)
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allob


    trigger OnRun()
    begin
        ActivateChangeLog;

        SetupObjectChangeLog('3;Payment Terms','All');
        SetupObjectChangeLog('4;Currency;','All');
        SetupObjectChangeLog('5;Finance Charge Terms;','All');
        SetupObjectChangeLog('14;Location;','All');
        SetupObjectChangeLog('15;G/L Account;','All');
        SetupObjectChangeLog('77;Report Selections;','All');
        SetupObjectChangeLog('78;Printer Selection;' ,'All');
        SetupObjectChangeLog('79;Company Information;' ,'All');
        SetupObjectChangeLog('91;User Setup;','All');
        SetupObjectChangeLog('98;General Ledger Setup;','All');
        SetupObjectChangeLog('242;Source Code Setup','All');
        SetupObjectChangeLog('252;General Posting Setup;','All');
        SetupObjectChangeLog('311;Sales & Receivables Setup;' ,'All');
        SetupObjectChangeLog('312;Purchases & Payables Setup;','All');
        SetupObjectChangeLog('313;Inventory Setup','All');
        SetupObjectChangeLog('325;VAT Posting Setup;' ,'All');
        SetupObjectChangeLog('6014400;Retail Setup;' ,'All');
        SetupObjectChangeLog('6014401;Register;' ,'All');
        SetupObjectChangeLog('6014402;Payment Type POS;' ,'All');
        SetupObjectChangeLog('6014410;Item Group;','All');
        SetupObjectChangeLog('6014428;Payment Type - Prefix;','All');
        Message(Text001);
    end;

    var
        Tabletext: Text[30];
        ArrayWord: array [100] of Text[30];
        Text001: Label 'Completed';

    procedure SetupObjectChangeLog(TableDetails: Text[1024];LogType: Text[30])
    var
        StringLib: Codeunit "String Library";
        i: Integer;
        ObjectType: Option "Table","Codeunit","Page";
        ObjectID: Integer;
        Obj: Boolean;
    begin
        StringLib.Construct(TableDetails);

        for i := 1 to StringLib.CountOccurences( ';' ) + 1 do begin
          ArrayWord[i] := StringLib.SelectStringSep( i, ';' );
        end;

        i := 0;
        for i := 1 to StringLib.CountOccurences( ';' ) + 1 do begin
          if (i mod 2) = 0 then begin
            Evaluate(ObjectID, ArrayWord[(i-1)]);
            if ValidateTable(ObjectType::Table, ObjectID, ArrayWord[i]) then begin
              InitTableLog(ObjectID,'All');
            end;
          end;
        end;
    end;

    procedure ValidateTable(ObjectType: Option "Table","Codeunit","Page";ObjectID: Integer;ObjectName: Text[100]) ObjectValid: Boolean
    var
        "Object": Record "Object";
        AllObj: Record AllObj;
    begin
        //-NPR5.46 [322752]
        // Object.RESET;
        // Object.SETRANGE(Type,ObjectType);
        // Object.SETRANGE(ID,ObjectID);
        // Object.SETRANGE(Name,ObjectName);
        // ObjectValid := Object.FINDFIRST;
        AllObj.Reset;
        AllObj.SetRange("Object Type",ObjectType);
        AllObj.SetRange("Object ID",ObjectID);
        AllObj.SetRange("Object Name",ObjectName);
        ObjectValid := AllObj.FindFirst;
        //+NPR5.46 [322752]
    end;

    procedure ActivateChangeLog()
    var
        ChangeLogSetup: Record "Change Log Setup";
    begin
        if ChangeLogSetup.Get then begin
          if ChangeLogSetup."Change Log Activated" then
            exit
          else
            ChangeLogSetup.ModifyAll(ChangeLogSetup."Change Log Activated",true,false);
        end
        else begin
          ChangeLogSetup.Init;
          ChangeLogSetup."Change Log Activated" := true;
          ChangeLogSetup.Insert;
        end;
    end;

    procedure InitTableLog(ObjectID: Integer;LogType: Text[30])
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        ChangeLogSetupTableInsrt: Record "Change Log Setup (Table)";
    begin
        ChangeLogSetupTable.Reset;
        ChangeLogSetupTable.SetRange("Table No.",ObjectID);
        if not ChangeLogSetupTable.FindFirst then begin

          case  LogType of
            '' : begin
              ChangeLogSetupTableInsrt.Init;
              ChangeLogSetupTableInsrt."Table No." := ObjectID;
              ChangeLogSetupTableInsrt.Validate("Log Insertion",ChangeLogSetupTableInsrt."Log Insertion"::" ");
              ChangeLogSetupTableInsrt.Validate("Log Modification",ChangeLogSetupTableInsrt."Log Modification"::" ");
              ChangeLogSetupTableInsrt.Validate("Log Deletion",ChangeLogSetupTableInsrt."Log Deletion"::" ");
              ChangeLogSetupTableInsrt.Insert;
            end;

            'Some' : begin
              ChangeLogSetupTableInsrt.Init;
              ChangeLogSetupTableInsrt."Table No." := ObjectID;
              ChangeLogSetupTableInsrt.Validate("Log Insertion",ChangeLogSetupTableInsrt."Log Insertion"::"Some Fields");
              ChangeLogSetupTableInsrt.Validate("Log Modification",ChangeLogSetupTableInsrt."Log Modification"::"Some Fields");
              ChangeLogSetupTableInsrt.Validate("Log Deletion",ChangeLogSetupTableInsrt."Log Deletion"::"Some Fields");
              ChangeLogSetupTableInsrt.Insert;
              //InitTableFieldsLog  NOT YET

            end;

            'All' : begin
              ChangeLogSetupTableInsrt.Init;
              ChangeLogSetupTableInsrt."Table No." := ObjectID;
              ChangeLogSetupTableInsrt.Validate("Log Insertion",ChangeLogSetupTableInsrt."Log Insertion"::"All Fields");
              ChangeLogSetupTableInsrt.Validate("Log Modification",ChangeLogSetupTableInsrt."Log Modification"::"All Fields");
              ChangeLogSetupTableInsrt.Validate("Log Deletion",ChangeLogSetupTableInsrt."Log Deletion"::"All Fields");
              ChangeLogSetupTableInsrt.Insert;
            end;
          end;
        end;
    end;

    procedure InitTableFieldsLog()
    begin
    end;
}


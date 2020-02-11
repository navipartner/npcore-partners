codeunit 6151102 "NpRi Reimbursement Mgt."
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.46/MHA /20181002  CASE 323942 Corrected Exit clause on "Reimbursement Date" in RunReimbursement()
    // NPR5.53/MHA /20191105  CASE 364131 Next Reimbursement Date should still be calculated even when no open entries

    TableNo = "NpRi Reimbursement";

    trigger OnRun()
    begin
        RunReimbursement(Rec);
    end;

    var
        Text000: Label 'Manual Application';
        Text001: Label 'Cancel Manual Application';
        Text002: Label 'Invalid Reimbursement module %1';

    local procedure "--- Setup Parameters"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure HasTemplateParameters(NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var HasParameters: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetupTemplateParameters(var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template")
    begin
    end;

    local procedure "--- Manual Apply"()
    begin
    end;

    procedure ManualApplyEntries(var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry")
    var
        xNpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
        NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry";
    begin
        NpRiReimbursementEntry.SetRange("Entry Type",NpRiReimbursementEntry."Entry Type"::"Data Collection");
        NpRiReimbursementEntry.SetRange(Open,true);
        if not NpRiReimbursementEntry.FindSet then
          exit;

        repeat
          if IsNewApplication(xNpRiReimbursementEntry,NpRiReimbursementEntry) then
            CreateManualApplicationEntry(NpRiReimbursementEntry,NpRiReimbursementEntryApply)
          else
            UpdateManualApplicationEntry(NpRiReimbursementEntry,NpRiReimbursementEntryApply);

          NpRiReimbursementEntry.Open := false;
          NpRiReimbursementEntry."Remaining Amount" := 0;
          NpRiReimbursementEntry."Closed by Entry No." := NpRiReimbursementEntryApply."Entry No.";
          NpRiReimbursementEntry.Modify;

          xNpRiReimbursementEntry := NpRiReimbursementEntry;
        until NpRiReimbursementEntry.Next = 0;
    end;

    local procedure CreateManualApplicationEntry(NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntryApply.Init;
        NpRiReimbursementEntryApply."Entry No." := 0;
        NpRiReimbursementEntryApply."Entry Type" := NpRiReimbursementEntryApply."Entry Type"::"Manual Application";
        NpRiReimbursementEntryApply."Party Type" := NpRiReimbursementEntry."Party Type";
        NpRiReimbursementEntryApply."Party No." := NpRiReimbursementEntry."Party No.";
        NpRiReimbursementEntryApply."Template Code" := NpRiReimbursementEntry."Template Code";
        NpRiReimbursementEntryApply.Description := Text000;
        NpRiReimbursementEntryApply.Amount := -NpRiReimbursementEntry."Remaining Amount";
        NpRiReimbursementEntryApply.Positive := NpRiReimbursementEntry.Amount > 0;
        NpRiReimbursementEntryApply.Open := false;
        NpRiReimbursementEntryApply."Remaining Amount" := 0;
        NpRiReimbursementEntryApply."Closed by Entry No." := NpRiReimbursementEntry."Entry No.";
        NpRiReimbursementEntryApply."Posting Date" := Today;
        NpRiReimbursementEntryApply."Document Type" := NpRiReimbursementEntry."Document Type"::" ";
        NpRiReimbursementEntryApply."Document No." := '';
        NpRiReimbursementEntryApply.Insert(true);

        NpRiReimbursementEntryApply."Source Company Name" := CompanyName;
        NpRiReimbursementEntryApply."Source Table No." := DATABASE::"NpRi Reimbursement Entry";
        NpRiReimbursementEntryApply."Source Record Position" := NpRiReimbursementEntryApply.GetPosition(false);
        NpRiReimbursementEntryApply."Source Entry No." := NpRiReimbursementEntryApply."Entry No.";
        NpRiReimbursementEntryApply.Modify;
    end;

    local procedure UpdateManualApplicationEntry(NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntryApply.Find;
        NpRiReimbursementEntryApply.TestField("Entry Type",NpRiReimbursementEntryApply."Entry Type"::"Manual Application");

        NpRiReimbursementEntryApply.Amount -= NpRiReimbursementEntry."Remaining Amount";
        NpRiReimbursementEntryApply.Positive := NpRiReimbursementEntry.Amount > 0;
        NpRiReimbursementEntryApply."Closed by Entry No." := NpRiReimbursementEntry."Entry No.";
        NpRiReimbursementEntryApply.Modify;
    end;

    local procedure IsNewApplication(xNpRiReimbursementEntry: Record "NpRi Reimbursement Entry";NpRiReimbursementEntry: Record "NpRi Reimbursement Entry"): Boolean
    begin
        exit(xNpRiReimbursementEntry."Template Code" <> NpRiReimbursementEntry."Template Code");
    end;

    local procedure "--- Cancel Manual Application"()
    begin
    end;

    procedure CancelManualApplication(var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry")
    var
        NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry";
    begin
        NpRiReimbursementEntry.TestField("Entry Type",NpRiReimbursementEntry."Entry Type"::"Manual Application");
        NpRiReimbursementEntry.TestField(Open,false);

        NpRiReimbursementEntry.Open := true;
        NpRiReimbursementEntry."Remaining Amount" := NpRiReimbursementEntry.Amount;
        NpRiReimbursementEntry."Closed by Entry No." := 0;
        NpRiReimbursementEntry.Modify;

        NpRiReimbursementEntryApply.SetRange(Open,false);
        NpRiReimbursementEntryApply.SetRange("Closed by Entry No.",NpRiReimbursementEntry."Entry No.");
        if not NpRiReimbursementEntryApply.FindSet then
          exit;

        repeat
          NpRiReimbursementEntryApply.Open := true;
          NpRiReimbursementEntryApply."Remaining Amount" := NpRiReimbursementEntryApply.Amount;
          NpRiReimbursementEntryApply."Closed by Entry No." := 0;
          NpRiReimbursementEntryApply.Modify;
        until NpRiReimbursementEntryApply.Next = 0;

        CreateCancelApplicationEntry(NpRiReimbursementEntry,NpRiReimbursementEntryApply);
        NpRiReimbursementEntry.Open := false;
        NpRiReimbursementEntry."Remaining Amount" := 0;
        NpRiReimbursementEntry."Closed by Entry No." := NpRiReimbursementEntryApply."Entry No.";
        NpRiReimbursementEntry.Modify;
    end;

    local procedure CreateCancelApplicationEntry(var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntryApply.Init;
        NpRiReimbursementEntryApply."Entry No." := 0;
        NpRiReimbursementEntryApply."Entry Type" := NpRiReimbursementEntryApply."Entry Type"::"Manual Application";
        NpRiReimbursementEntryApply."Party Type" := NpRiReimbursementEntry."Party Type";
        NpRiReimbursementEntryApply."Party No." := NpRiReimbursementEntry."Party No.";
        NpRiReimbursementEntryApply."Template Code" := NpRiReimbursementEntry."Template Code";
        NpRiReimbursementEntryApply.Description := Text001;
        NpRiReimbursementEntryApply.Amount := -NpRiReimbursementEntry."Remaining Amount";
        NpRiReimbursementEntryApply.Positive := NpRiReimbursementEntry.Amount > 0;
        NpRiReimbursementEntryApply.Open := false;
        NpRiReimbursementEntryApply."Remaining Amount" := 0;
        NpRiReimbursementEntryApply."Closed by Entry No." := NpRiReimbursementEntry."Entry No.";
        NpRiReimbursementEntryApply."Posting Date" := Today;
        NpRiReimbursementEntryApply."Document Type" := NpRiReimbursementEntry."Document Type"::" ";
        NpRiReimbursementEntryApply."Document No." := '';
        NpRiReimbursementEntryApply.Insert(true);

        NpRiReimbursementEntryApply."Source Company Name" := CompanyName;
        NpRiReimbursementEntryApply."Source Table No." := DATABASE::"NpRi Reimbursement Entry";
        NpRiReimbursementEntryApply."Source Record Position" := NpRiReimbursementEntryApply.GetPosition(false);
        NpRiReimbursementEntryApply."Source Entry No." := NpRiReimbursementEntryApply."Entry No.";
        NpRiReimbursementEntryApply.Modify;
    end;

    local procedure "--- Reimbursement"()
    begin
    end;

    procedure RunReimbursements(var NpRiReimbursement: Record "NpRi Reimbursement")
    begin
        if NpRiReimbursement.FindSet then
          repeat
            RunReimbursement(NpRiReimbursement);
            Commit;
          until NpRiReimbursement.Next = 0;
    end;

    procedure RunReimbursement(var NpRiReimbursement: Record "NpRi Reimbursement")
    var
        NpRiParty: Record "NpRi Party";
        NpRiReimbursement2: Record "NpRi Reimbursement";
        NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
        NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry";
        Handled: Boolean;
    begin
        if not NpRiParty.Get(NpRiReimbursement."Party Type",NpRiReimbursement."Party No.") then
          exit;
        //-NPR5.53 [364131]
        if not FindOpenEntries(NpRiReimbursement,NpRiReimbursementEntry) then begin
          NpRiReimbursement."Last Posting Date" := NpRiReimbursement."Posting Date";
          NpRiReimbursement."Last Reimbursement at" := CurrentDateTime;
          NpRiReimbursement."Posting Date" := 0D;
          if Format(NpRiParty."Next Posting Date Calculation") <> '' then
            NpRiReimbursement."Posting Date" := CalcDate(NpRiParty."Next Posting Date Calculation",NpRiReimbursement."Last Posting Date");
          NpRiReimbursement."Reimbursement Date" := 0D;
          if Format(NpRiParty."Reimburse every") <> '' then
            NpRiReimbursement."Reimbursement Date" := CalcDate(NpRiParty."Reimburse every",DT2Date(NpRiReimbursement."Last Reimbursement at"));
          NpRiReimbursement.Modify(true);

          exit;
        end;
        //+NPR5.53 [364131]
        //-NPR5.46 [323942]
        if NpRiReimbursement."Reimbursement Date" = 0D then
          exit;
        if NpRiReimbursement."Reimbursement Date" > Today then
          exit;
        //+NPR5.46 [323942]

        NpRiReimbursement.TestField("Posting Date");
        ReimburseApplyEntries(NpRiReimbursement,NpRiReimbursementEntry,NpRiReimbursementEntryApply);
        NpRiReimbursement.CalcFields("Reimbursement Module");
        OnRunReimbursement(NpRiReimbursement,NpRiReimbursementEntryApply,Handled);
        if not Handled then
          Error(Text002,NpRiReimbursement."Reimbursement Module");

        NpRiReimbursement2 := NpRiReimbursement;
        NpRiReimbursement.Find;
        NpRiReimbursement := NpRiReimbursement2;
        NpRiReimbursement."Last Posting Date" := NpRiReimbursement."Posting Date";
        NpRiReimbursement."Last Reimbursement at" := CurrentDateTime;
        NpRiReimbursement."Posting Date" := 0D;
        if Format(NpRiParty."Next Posting Date Calculation") <> '' then
          NpRiReimbursement."Posting Date" := CalcDate(NpRiParty."Next Posting Date Calculation",NpRiReimbursement."Last Posting Date");
        NpRiReimbursement."Reimbursement Date" := 0D;
        if Format(NpRiParty."Reimburse every") <> '' then
          NpRiReimbursement."Reimbursement Date" := CalcDate(NpRiParty."Reimburse every",DT2Date(NpRiReimbursement."Last Reimbursement at"));
        NpRiReimbursement.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunReimbursement(var NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry";var Handled: Boolean)
    begin
    end;

    local procedure FindOpenEntries(NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry"): Boolean
    begin
        Clear(NpRiReimbursementEntry);
        NpRiReimbursementEntry.SetCurrentKey("Party Type","Party No.","Template Code","Entry Type",Open,"Posting Date");
        NpRiReimbursementEntry.SetRange("Party Type",NpRiReimbursement."Party Type");
        NpRiReimbursementEntry.SetRange("Party No.",NpRiReimbursement."Party No.");
        NpRiReimbursementEntry.SetRange("Template Code",NpRiReimbursement."Template Code");
        NpRiReimbursementEntry.SetRange("Entry Type",NpRiReimbursementEntry."Entry Type"::"Data Collection");
        NpRiReimbursementEntry.SetRange(Open,true);
        NpRiReimbursementEntry.SetFilter("Posting Date",'<=%1',NpRiReimbursement."Posting Date");
        exit(NpRiReimbursementEntry.FindFirst);
    end;

    local procedure ReimburseApplyEntries(NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    begin
        if NpRiReimbursementEntry.IsEmpty then
          exit;

        NpRiReimbursementEntry.CalcSums(Amount);
        CreateReimbursementApplicationEntry(NpRiReimbursement,-NpRiReimbursementEntry.Amount,NpRiReimbursementEntryApply);

        NpRiReimbursementEntry.FindLast;
        NpRiReimbursementEntry.ModifyAll("Remaining Amount",0);
        NpRiReimbursementEntry.ModifyAll("Closed by Entry No.",NpRiReimbursementEntryApply."Entry No.");
        NpRiReimbursementEntry.ModifyAll(Open,false);

        NpRiReimbursementEntryApply."Remaining Amount" := 0;
        NpRiReimbursementEntryApply.Open := false;
        NpRiReimbursementEntryApply."Closed by Entry No." := NpRiReimbursementEntry."Entry No.";
        NpRiReimbursementEntryApply.Modify(true);
    end;

    local procedure CreateReimbursementApplicationEntry(NpRiReimbursement: Record "NpRi Reimbursement";Amount: Decimal;var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    var
        NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";
    begin
        NpRiReimbursementTemplate.Get(NpRiReimbursement."Template Code");
        if NpRiReimbursementTemplate."Posting Description" = '' then
          NpRiReimbursementTemplate."Posting Description" := NpRiReimbursementTemplate.Description;

        NpRiReimbursementEntryApply.Init;
        NpRiReimbursementEntryApply."Entry No." := 0;
        NpRiReimbursementEntryApply."Entry Type" := NpRiReimbursementEntryApply."Entry Type"::Reimbursement;
        NpRiReimbursementEntryApply."Party Type" := NpRiReimbursement."Party Type";
        NpRiReimbursementEntryApply."Party No." := NpRiReimbursement."Party No.";
        NpRiReimbursementEntryApply."Template Code" := NpRiReimbursement."Template Code";
        NpRiReimbursementEntryApply.Description := NpRiReimbursementTemplate."Posting Description";
        NpRiReimbursementEntryApply."Source Company Name" := CompanyName;
        NpRiReimbursementEntryApply.Amount := Amount;
        NpRiReimbursementEntryApply.Positive := NpRiReimbursementEntryApply.Amount > 0;
        NpRiReimbursementEntryApply.Open := true;
        NpRiReimbursementEntryApply."Remaining Amount" := NpRiReimbursementEntryApply.Amount;
        NpRiReimbursementEntryApply."Posting Date" := NpRiReimbursement."Posting Date";
        NpRiReimbursementEntryApply.Insert(true);

        NpRiReimbursementEntryApply."Document No." := Format(NpRiReimbursementEntryApply."Entry No.");
        NpRiReimbursementEntryApply.Modify(true);
    end;
}


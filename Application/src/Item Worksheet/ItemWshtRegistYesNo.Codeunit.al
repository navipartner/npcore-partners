codeunit 6060043 "NPR Item Wsht.-Regist.(Yes/No)"
{
    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        ItemWkshLine.Copy(Rec);
        Code();
        Rec.Copy(ItemWkshLine);
    end;

    var
        ItemWkshLine: Record "NPR Item Worksheet Line";
        RegisterWrkshLineQst: Label 'Do you want to register the worksheet lines?';
        SomeLinesNotProcessedMsg: Label 'Some worksheet lines could not be processed because of errors.';
        NothingToRegisterMsg: Label 'There is nothing to register.';
        WrkshLineRegisteredMsg: Label 'The worksheet lines were successfully registered.';

    local procedure "Code"()
    begin
        if not Confirm(RegisterWrkshLineQst) then
            exit;

        CODEUNIT.Run(CODEUNIT::"NPR Item Wsht.-Regist. Batch", ItemWkshLine);

        if ItemWkshLine."Line No." = 0 then
            Message(NothingToRegisterMsg);

        ItemWkshLine.SetFilter(Status, '<>%1', ItemWkshLine.Status::Processed);
        ItemWkshLine.SetFilter(Action, '<>%1', ItemWkshLine.Action::Skip);

        if not ItemWkshLine.Find('=><') then begin
            Message(WrkshLineRegisteredMsg);
            ItemWkshLine."Line No." := 10000;
            ItemWkshLine.SetUpNewLine(ItemWkshLine);
        end else begin
            Message(SomeLinesNotProcessedMsg);
        end;
        ItemWkshLine.SetRange(Action);
        ItemWkshLine.SetRange(Status);
    end;
}


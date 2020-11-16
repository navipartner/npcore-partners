codeunit 6060043 "NPR Item Wsht.-Regist.(Yes/No)"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.19\BR\20160216  CASE 182391 Fix error message if lines are not deleted after processing

    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        ItemWkshLine.Copy(Rec);
        Code;
        Copy(ItemWkshLine);
    end;

    var
        ItemWkshLine: Record "NPR Item Worksheet Line";
        Text001: Label 'Do you want to register the worksheet lines?';
        Text002: Label 'There is nothing to register.';
        Text003: Label 'The worksheet lines were successfully registered.';
        Text004: Label 'Some worksheet lines could not be processed because of errors.';

    local procedure "Code"()
    begin
        with ItemWkshLine do begin
            if not Confirm(Text001) then
                exit;

            CODEUNIT.Run(CODEUNIT::"NPR Item Wsht.-Regist. Batch", ItemWkshLine);

            if "Line No." = 0 then
                Message(Text002);

            //-NPR4.19
            SetFilter(Status, '<>%1', Status::Processed);
            SetFilter(Action, '<>%1', Action::Skip);
            //+NPR4.19
            if not Find('=><') then begin
                Message(Text003);
                "Line No." := 10000;
                SetUpNewLine(ItemWkshLine);
            end else begin
                Message(Text004);
            end;
            //-NPR4.19
            SetRange(Action);
            SetRange(Status);
            //+NPR4.19
        end;
    end;
}


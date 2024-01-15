page 6151379 "NPR Create TicketType Step"
{
    Extensible = False;
    Caption = 'Ticket Types';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR TM Ticket Type";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the record.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Print Ticket"; Rec."Print Ticket")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the ticket should be printed or not. Print often happens during sale on POS.';
                }
                field("Print Object Type"; Rec."Print Object Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if print should be handled by Codeunit, Retail print template, or a Report.';
                }
                field("RP Template Code"; Rec."RP Template Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the RP Template Code used to print the ticket.';
                }
                field("Admission Registration"; Rec."Admission Registration")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the ticket should be issued as individual tickets, or as one group ticket.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the numberseries used to issue the ticket.';
                }
                field("External Ticket Pattern"; Rec."External Ticket Pattern")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the External Ticket Pattern. The pattern can include fixed text, the original ticket number and random characters. Any characters not within the [ and ] will be treated as fixed text. [S] – Will be substituted with the original ticket number from no. series. The following modifiers can be used. [N] – Random number, [N*4] – 4 random numbers, [A] – Random character, [A*4] – 4 random characters An example could be: TK-[S]-[N*4] which would result in TK-<ticket number>-<four random numbers>';
                }
                field("Activation Method"; Rec."Activation Method")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Activation Method. POS (Default), will admit the default admission after sale from POS. POS (All Admissions), Will admit all the admissions after sale on POS. Scan will require the ticket to be scanned for admission.';
                }
                field("Ticket Configuration Source"; Rec."Ticket Configuration Source")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies Ticket Configuration Source. Ticket Type, will use the settings defined on the specific Type. Ticket BOM, will use the settings defined per ticket item on Ticket BOM table.';
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ticket Duration Formula field. The following modifiers apply. C, D, M and Y. Use 1Y for a validity of 1 year. or 30D for 30 days.';
                }
                field("Ticket Entry Validation"; Rec."Ticket Entry Validation")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies Ticket Entry Validation. Single will allow for one single use per admission. Same day will allow for unlimited uses per admission, on the same date as first admission. Multiple will allow for a number of uses per admission, as specified in "Max No of entried" spanning across multiple days.';
                }
                field("Max No. Of Entries"; Rec."Max No. Of Entries")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Max No. Of Entries allowed, when Ticket entry validation is set for "Multiple';
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        TicektTypes: Record "NPR TM Ticket Type";
    begin
        Rec.DeleteAll();

        if TicektTypes.FindSet() then
            repeat
                Rec := TicektTypes;
                if not Rec.Insert() then
                    Rec.Modify();
            until TicektTypes.Next() = 0;
    end;

    internal procedure TicketTypesToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateTicketTypes()
    var
        TicketTypes: Record "NPR TM Ticket Type";
    begin
        if Rec.FindSet() then
            repeat
                TicketTypes := Rec;
                if not TicketTypes.Insert() then
                    TicketTypes.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempTicketTypes(var TempTicketTypes: Record "NPR TM Ticket Type")
    begin
        TempTicketTypes.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempTicketTypes := Rec;
                if not TempTicketTypes.Insert() then
                    TempTicketTypes.Modify();
            until Rec.Next() = 0;
    end;
}

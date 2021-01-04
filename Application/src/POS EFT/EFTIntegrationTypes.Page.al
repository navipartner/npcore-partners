page 6184483 "NPR EFT Integration Types"
{
    // NPR5.30/BR  /20170113  CASE 263458 Object Created
    // NPR5.46/MMV /20180926 CASE 290734 EFT Framework refactored

    Caption = 'EFT Integration Types';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR EFT Integration Type";
    SourceTableTemporary = true;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Codeunit ID"; "Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit ID field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        //-NPR5.46 [290734]
        if Rec.IsEmpty then begin
            EFTInterface.OnDiscoverIntegrations(Rec);
        end;
        //+NPR5.46 [290734]
    end;
}


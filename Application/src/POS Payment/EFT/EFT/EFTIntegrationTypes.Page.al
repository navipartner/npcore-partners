page 6184483 "NPR EFT Integration Types"
{
    Extensible = False;
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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique identifier of the EFT Integration Type.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the Description of EFT Integration Type.';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {

                    ToolTip = 'Specifies which Codeunit ID is used with the selected integration.';
                    ApplicationArea = NPRRetail;
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


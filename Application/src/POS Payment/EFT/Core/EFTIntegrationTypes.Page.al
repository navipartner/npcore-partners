page 6184483 "NPR EFT Integration Types"
{
    Extensible = False;
    Caption = 'EFT Integration Types';
    ContextSensitiveHelpPage = 'docs/retail/eft/explanation/integration_types/';
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
        if Rec.IsEmpty then begin
            EFTInterface.OnDiscoverIntegrations(Rec);
        end;
    end;
}


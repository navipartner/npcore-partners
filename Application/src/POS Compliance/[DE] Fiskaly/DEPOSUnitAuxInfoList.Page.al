page 6014427 "NPR DE POS Unit Aux. Info List"
{
    Caption = 'NPR DE POS Unit Aux. Info List';
    PageType = List;
    SourceTable = "NPR DE POS Unit Aux. Info";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of POS Unit No.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of Serial Number for DE Fiskaly';
                }
                field("TSS ID"; Rec."TSS ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of TSS ID for DE Fiskaly';
                }
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of Client ID for DE Fiskaly';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create TSS Client ID")
            {
                Caption = 'Create Fiskaly TSS/Client';
                Image = Create;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Creates TSS and Client ID on Fiskaly for DE fiscalization.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    CreateTSSLbl: Label 'TSS ID already exists, this action will create New TSS ID and Client ID. Do you want to continue?';
                begin
                    //Fiskaly recomendation for now is to have TSS and Client 1 to 1.
                    Rec.TestField("Serial Number");
                    if not IsNullGuid(Rec."TSS ID") then
                        if not Confirm(CreateTSSLbl) then
                            exit;
                    DEFiskalyCommunication.CreateTSSClient(Rec);
                    CurrPage.Update();
                end;
            }
        }
    }
}
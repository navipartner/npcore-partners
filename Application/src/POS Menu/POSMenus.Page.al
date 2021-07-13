page 6150701 "NPR POS Menus"
{
    Caption = 'POS Menus';
    PageType = List;
    SourceTable = "NPR POS Menu";
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Caption; Rec.Caption)
                {

                    ToolTip = 'Specifies the value of the Caption field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Register Type"; Rec."Register Type")
                {

                    ToolTip = 'Specifies the value of the POS View Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Buttons)
            {
                Caption = 'Buttons';
                Image = Hierarchy;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Menu Buttons";
                RunPageLink = "Menu Code" = FIELD(Code);

                ToolTip = 'Executes the Buttons action';
                ApplicationArea = NPRRetail;
            }
            action(ExportPackageSelected)
            {
                Caption = 'Export Package (Selected)';
                Image = Export;

                ToolTip = 'Executes the Export Package (Selected) action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPackageHandler: Codeunit "NPR POS Package Handler";
                    POSMenu: Record "NPR POS Menu";
                begin
                    CurrPage.SetSelectionFilter(POSMenu);
                    POSPackageHandler.ExportPOSMenuPackageToFile(POSMenu);
                end;
            }
            action(ExportPackageAll)
            {
                Caption = 'Export Package (All)';
                Image = Export;

                ToolTip = 'Executes the Export Package (All) action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPackageHandler: Codeunit "NPR POS Package Handler";
                    POSMenu: Record "NPR POS Menu";
                begin
                    POSPackageHandler.ExportPOSMenuPackageToFile(POSMenu);
                end;
            }
            action(ImportPackage)
            {
                Caption = 'Import Package From File';
                Image = Import;

                ToolTip = 'Executes the Import Package From File action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPackageHandler: Codeunit "NPR POS Package Handler";
                begin
                    POSPackageHandler.ImportPOSMenuPackageFromFile();
                end;
            }
            action(DeployPackageFromAzureBlob)
            {
                Caption = 'Download Template Data';
                Image = ImportDatabase;

                RunObject = page "NPR POS Menu Deploy from Azure";
                ToolTip = 'Downloads template data.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}


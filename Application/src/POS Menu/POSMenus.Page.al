page 6150701 "NPR POS Menus"
{
    Caption = 'POS Menus';
    PageType = List;
    SourceTable = "NPR POS Menu";
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
                field(Caption; Caption)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Caption field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Register Type"; "Register Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register Type field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Available on Desktop"; "Available on Desktop")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Available on Desktop field';
                }
                field("Available in App"; "Available in App")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Available in App field';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Menu Buttons";
                RunPageLink = "Menu Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Buttons action';
            }
            action(ExportPackageSelected)
            {
                Caption = 'Export Package (Selected)';
                Image = Export;
                ApplicationArea = All;
                ToolTip = 'Executes the Export Package (Selected) action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Export Package (All) action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Import Package From File action';

                trigger OnAction()
                var
                    POSPackageHandler: Codeunit "NPR POS Package Handler";
                begin
                    POSPackageHandler.ImportPOSMenuPackageFromFile();
                end;
            }
            action(DeployPackageFromAzureBlob)
            {
                Caption = 'Deploy Package From Azure';
                Image = ImportDatabase;
                ApplicationArea = All;
                RunObject = page "NPR POS Menu Deploy from Azure";
                ToolTip = 'Executes the Deploy Package From Azure action';
            }
        }
    }
}


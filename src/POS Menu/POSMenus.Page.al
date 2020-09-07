page 6150701 "NPR POS Menus"
{
    // NPR5.35.01/JDH /20170905 CASE        Added action to convert POS Touchscreen to transcendence
    // NPR5.48/BHR /20181206 CASE 338656 Added Missing Picture to Action

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
                }
                field(Caption; Caption)
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Register Type"; "Register Type")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Available on Desktop"; "Available on Desktop")
                {
                    ApplicationArea = All;
                }
                field("Available in App"; "Available in App")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;
            }
            action(ExportPackageSelected)
            {
                Caption = 'Export Package (Selected)';
                Image = Export;
                ApplicationArea=All;

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
                ApplicationArea=All;

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
                ApplicationArea=All;

                trigger OnAction()
                var
                    POSPackageHandler: Codeunit "NPR POS Package Handler";
                begin
                    POSPackageHandler.ImportPOSMenuPackageFromFile();
                end;
            }
            action(DeployPackage)
            {
                Caption = 'Deploy Package From Ground Control';
                Image = ImportDatabase;
                ApplicationArea=All;

                trigger OnAction()
                var
                    POSPackageHandler: Codeunit "NPR POS Package Handler";
                begin
                    POSPackageHandler.DeployPOSMenuPackageFromGroundControl();
                end;
            }
        }
    }
}


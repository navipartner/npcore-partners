page 6150701 "NPR POS Menus"
{
    Extensible = False;
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

                    ToolTip = 'Specifies what the caption is';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies whether it"s blocked or not';
                    ApplicationArea = NPRRetail;
                }
                field("Register Type"; Rec."Register Type")
                {

                    ToolTip = 'Specifies what POS View Profile is assigned';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies what POS Unit is assigned';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies what salesperson is assigned';
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

                ToolTip = 'Create/delete and edit POS Menu buttons';
                ApplicationArea = NPRRetail;
            }
            action(ExportPackageSelected)
            {
                Caption = 'Export Package (Selected)';
                Image = Export;

                ToolTip = 'Exports the selected package';
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

                ToolTip = 'Exports all the packages';
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

                ToolTip = 'Imports a package from a file';
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


page 6150701 "NPR POS Menus"
{
    Extensible = False;
    Caption = 'POS Menus';
    ContextSensitiveHelpPage = 'docs/retail/pos_layout/explanation/sections/';
    PageType = List;
    SourceTable = "NPR POS Menu";
    UsageCategory = Administration;
    ApplicationArea = NPRNewPOSEditor;

#if not BC17
    AboutTitle = 'About POS Menus';
    AboutText = 'This list shows all POS menus available for POS views and for pop-up buttons.';
#endif


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this POS menu.';
                    ApplicationArea = NPRRetail;
                }
                field(Caption; Rec.Caption)
                {
                    ToolTip = 'Specifies a text that describes the POS menu.';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {
                    ToolTip = 'Specifies the POS unit this POS menu will only be used for. Leave blank, if you want the POS menu to be used for any POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the salesperson code this POS menu will only be used for. Leave blank, if you want the POS menu to be used for any salesperson.';
                    ApplicationArea = NPRRetail;
                }
                field("Register Type"; Rec."Register Type")
                {
                    ToolTip = 'Specifies the POS view profile this POS menu will only be used for. Leave blank, if you want the POS menu to be used for any POS view profile.';
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
#if not BC17
                AboutTitle = 'Seeing the POS Buttons';
                AboutText = 'After selecting a **POS Menu**, you need to click the **Buttons** action to open the list of **POS Buttons** in the selected **POS Menu**.';
#endif
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
#if not BC17
                AboutTitle = 'Importing or exporting POS Menus';
                AboutText = 'In **Actions** you can find options to import or export POS menus as JSON packages. When importing packages, be aware that non-existing POS menus or items used in POS buttons will not be automatically created.';
#endif

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


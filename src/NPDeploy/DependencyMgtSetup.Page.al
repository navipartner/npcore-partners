page 6014670 "NPR Dependency Mgt. Setup"
{
    // NPR5.01/VB/20160215 CASE 234462 Object created to support managed dependency deployment
    // #243906/JDH/20160706 CASE 243906 Added setup + download actions
    // NPR5.26/MMV /20160905 CASE 242977 Added field 17

    Caption = 'Dependency Management Setup';
    PageType = Card;
    SourceTable = "NPR Dependency Mgt. Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Configuration)
                {
                    Caption = 'Configuration';
                    field("OData URL"; "OData URL")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            InvalidateManagedDependencies();
                        end;
                    }
                    field(Username; Username)
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            InvalidateManagedDependencies();
                        end;
                    }
                    field(ManagedDependencyPassword; ManagedDependencyPassword)
                    {
                        ApplicationArea = All;
                        Editable = PasswordEditable;
                        ExtendedDatatype = Masked;

                        trigger OnValidate()
                        begin
                            InvalidateManagedDependencies();
                            StoreManagedDependencyPassword(ManagedDependencyPassword);
                            CurrPage.SaveRecord();
                        end;
                    }
                    field(Configured; Configured)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Disable Deployment"; "Disable Deployment")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Filtering)
                {
                    Caption = 'Filtering';
                    field("Accept Statuses"; "Accept Statuses")
                    {
                        ApplicationArea = All;
                    }
                    field("Tag Filter"; "Tag Filter")
                    {
                        ApplicationArea = All;
                        Caption = 'Tag Filter (Comma Separated)';
                    }
                    field("Tag Filter Comparison Operator"; "Tag Filter Comparison Operator")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Validate Managed Dependencies")
            {
                Caption = 'Validate Managed Dependencies';
                Image = TestDatabase;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    //-NPR5.01
                    ValidateManagedDependencySetup();
                    //+NPR5.01
                end;
            }
            action("Setup Managed Dependecy")
            {
                Caption = 'Setup Managed Dependecy';
                Image = Setup;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    InstallDependencies: Codeunit "NPR Install Mng. Dependencies";
                begin
                    //-243906
                    InstallDependencies.InsertBaseData;
                    //+243906
                end;
            }
            action("Download Managed Dependencies")
            {
                Caption = 'Download Managed Dependencies';
                Image = ImportCodes;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    InstallDependencies: Codeunit "NPR Install Mng. Dependencies";
                begin
                    //-243906
                    InstallDependencies.DownloadManagedDependecies;
                    //+243906
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Password.HasValue then
            ManagedDependencyPassword := GetManagedDependencyPassword();
        PasswordEditable := CurrPage.Editable;
    end;

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;

    var
        ManagedDependencyPassword: Text;
        [InDataSet]
        PasswordEditable: Boolean;

    local procedure InvalidateManagedDependencies()
    begin
        Configured := false;
    end;

    local procedure ValidateManagedDependencySetup()
    var
        ManagedDepMgt: Codeunit "NPR Managed Dependency Mgt.";
        ErrorMessage: Text;
        TextOk: Label 'Managed Dependency OData web service has been configured successfully. Your external dependencies will now be managed centrally by Ground Control.';
    begin
        TestField("OData URL");
        ManagedDepMgt.ValidateGroundControlConfiguration(Rec);
        Configured := true;
        CurrPage.SaveRecord();
        Message(TextOk);
    end;
}


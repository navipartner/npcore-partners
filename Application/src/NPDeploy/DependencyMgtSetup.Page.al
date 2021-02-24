page 6014670 "NPR Dependency Mgt. Setup"
{
    Caption = 'Dependency Management Setup';
    PageType = Card;
    SourceTable = "NPR Dependency Mgt. Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Configuration)
                {
                    Caption = 'Configuration';
                    field("Disable Deployment"; "Disable Deployment")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Disable Deployment field';
                    }
                }
                group(Filtering)
                {
                    Caption = 'Filtering';
                    field("Accept Statuses"; "Accept Statuses")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Accept Dependency Statuses field';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Download Managed Dependencies")
            {
                Caption = 'Download Managed Dependencies';
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Download Managed Dependencies action';

                trigger OnAction()
                var
                    ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
                begin
                    ManagedDependencyMgt.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}


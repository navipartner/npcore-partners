#if not CLOUD
page 6014670 "NPR Dependency Mgt. Setup"
{
    Extensible = False;
    Caption = 'Dependency Management Setup';
    PageType = Card;
    SourceTable = "NPR Dependency Mgt. Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                group(Configuration)
                {
                    Caption = 'Configuration';
                    field("Disable Deployment"; Rec."Disable Deployment")
                    {

                        ToolTip = 'Specifies the value of the Disable Deployment field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Filtering)
                {
                    Caption = 'Filtering';
                    field("Accept Statuses"; Rec."Accept Statuses")
                    {

                        ToolTip = 'Specifies the value of the Accept Dependency Statuses field';
                        ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Download Managed Dependencies action';
                ApplicationArea = NPRRetail;

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
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
#endif

page 6059889 "Npm Views"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Page Manager - Views';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Page Manager';
    SourceTable = "Npm View";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No.";"Table No.")
                {
                    ShowMandatory = true;
                }
                field("Code";Code)
                {
                    ShowMandatory = true;
                }
                field("Table Name";"Table Name")
                {
                }
                field("Mandatory Field Qty.";"Mandatory Field Qty.")
                {
                }
                field("Field Caption Qty.";"Field Caption Qty.")
                {
                }
            }
            grid(Control6014417)
            {
                ShowCaption = false;
                group(Control6014408)
                {
                    ShowCaption = false;
                    part("Mandatory Fields";"Npm Mandatory Fields")
                    {
                        Caption = 'Mandatory Fields';
                        SubPageLink = "Table No."=FIELD("Table No."),
                                      "View Code"=FIELD(Code);
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                    part("Validation Conditions";"Npm View Conditions")
                    {
                        Caption = 'Validation Conditions';
                        ShowFilter = false;
                        SubPageLink = "Table No."=FIELD("Table No."),
                                      "View Code"=FIELD(Code);
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Apply Page Manager changes")
            {
                Caption = 'Apply All Page Manager changes';
                Image = NewRow;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpmPageMetadata: Record "Npm Page";
                    NpmMetadataMgt: Codeunit "Npm Metadata Mgt.";
                begin
                    NpmPageMetadata.SetRange("Npm Enabled",true);
                    if NpmPageMetadata.IsEmpty then
                      exit;

                    NpmPageMetadata.FindSet;
                    repeat
                      NpmMetadataMgt.ApplyNpmChanges(NpmPageMetadata);
                    until NpmPageMetadata.Next = 0;
                    Message(Text000);
                end;
            }
            action("Reset All Page Manger changes")
            {
                Caption = 'Reset All Page Manager changes';
                Image = RemoveLine;

                trigger OnAction()
                var
                    NpmPageMetadata: Record "Npm Page";
                    NpmMetadataMgt: Codeunit "Npm Metadata Mgt.";
                begin
                    NpmPageMetadata.SetRange("Npm Enabled",true);
                    if NpmPageMetadata.IsEmpty then
                      exit;

                    NpmPageMetadata.FindSet;
                    repeat
                      NpmMetadataMgt.ResetNpmMetadata(NpmPageMetadata);
                    until NpmPageMetadata.Next = 0;
                    Message(Text001);
                end;
            }
        }
        area(navigation)
        {
            action("Field Captions")
            {
                Caption = 'Field Captions';
                Image = Language;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Npm Fields";
                RunPageLink = Type=CONST(Caption),
                              "Table No."=FIELD("Table No."),
                              "View Code"=FIELD(Code);
            }
            action(Pages)
            {
                Caption = 'Pages';
                Image = ViewPage;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpmViewPages: Page "Npm View Pages";
                begin
                    NpmViewPages.SetNpmView(Rec);
                    NpmViewPages.Run;
                end;
            }
        }
    }

    var
        Text000: Label 'Page Manager changes applied';
        Text001: Label 'Page Manager changes removed';
}


page 6059970 "NPR Variety Setup"
{
    Caption = 'Variety Setup';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,View,Update';
    SourceTable = "NPR Variety Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Variety Enabled"; Rec."Variety Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Enabled field';
                }
                field("Item Journal Blocking"; Rec."Item Journal Blocking")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Blocking field';
                }
                field("Variant Description"; Rec."Variant Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Description field';
                }
                field("Variant Description 2"; Rec."Variant Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Description 2 field';
                }
                field("Create Variant Code From"; Rec."Create Variant Code From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Variant Code From field';
                }
                field("Variant No. Series"; Rec."Variant No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Std. No. Serie field. Number series must be maximum 10 characters long.';
                }
            }
            group("Barcode (Item Cross Ref.)")
            {
                Caption = 'Barcode (Item Cross Ref.)';
                field("Create Item Cross Ref. auto."; Rec."Create Item Cross Ref. auto.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Item Cross Ref. auto. field';
                }
                field("Barcode Type (Item Cross Ref.)"; Rec."Barcode Type (Item Cross Ref.)")
                {
                    ApplicationArea = All;
                    Editable = "Create Item Cross Ref. auto.";
                    ToolTip = 'Specifies the value of the Barcode Type (Item Cross Ref.) field';
                }
                field("Item Cross Ref. No. Series (I)"; Rec."Item Cross Ref. No. Series (I)")
                {
                    ApplicationArea = All;
                    Editable = Rec."Create Item Cross Ref. auto.";
                    ToolTip = 'Specifies the value of the Item Cross Ref. No. Series (Item) field';

                    trigger OnValidate()
                    begin
                        if Rec."Item Cross Ref. No. Series (V)" = '' then
                            Rec."Item Cross Ref. No. Series (V)" := Rec."Item Cross Ref. No. Series (I)";
                    end;
                }
                field("Item Cross Ref. No. Series (V)"; Rec."Item Cross Ref. No. Series (V)")
                {
                    ApplicationArea = All;
                    Editable = Rec."Create Item Cross Ref. auto.";
                    ToolTip = 'Specifies the value of the Item Cross Ref. No. Series (Variant) field';
                }
                field("Item Cross Ref. Description(I)"; Rec."Item Cross Ref. Description(I)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Cross Ref. Description (Item) field';
                }
                field("Item Cross Ref. Description(V)"; Rec."Item Cross Ref. Description(V)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Cross Ref. Description (Variant) field';
                }
                field("Internal EAN No. Series"; Rec."Internal EAN No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Internal EAN No. Series field';
                }
                field("External EAN No. Series"; Rec."External EAN No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External EAN No. Series field';
                }
                field("EAN-Internal"; "EAN-Internal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EAN-Internal field';
                }
                field("EAN-External"; "EAN-External")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EAN-External field';
                }
            }
            group(View)
            {
                Caption = 'View';
                field("Hide Inactive Values"; "Hide Inactive Values")
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether Inactive Values should be hidden in the Variant Matrix by default';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Create Barcode No. Series")
            {
                Caption = 'Create Barcode No. Series';
                action("EAN13 Internal")
                {
                    Caption = 'EAN13 Internal';
                    Image = BarCode;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the EAN13 Internal action';

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VRTCloneData.CreateEAN13BarcodeNoSeries(true);
                    end;
                }
                action("EAN13 External")
                {
                    Caption = 'EAN13 External';
                    Image = BarCode;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the EAN13 External action';

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VRTCloneData.CreateEAN13BarcodeNoSeries(false);
                    end;
                }
            }
            group("Copy Barcode Setup")
            {
                Caption = 'Copy Barcode Setup';
                action("Show Original Setup")
                {
                    Caption = 'Show Original Setup';
                    Image = History;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Original Setup action';

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VRTCloneData.ShowEAN13BarcodeNoSetup();
                    end;
                }
                action("Item Reference")
                {
                    Caption = 'Item Reference';
                    Image = BarCode;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Reference Entries";
                    RunPageView = SORTING("Reference Type", "Reference No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Cross Reference action';
                }
            }
            group("Update")
            {
                Caption = 'Update';
                action("Item Variant Descriptions")
                {
                    Caption = 'Item Variant Descriptions';
                    Image = UpdateDescription;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Variant Descriptions action';

                    trigger OnAction()
                    var
                        VrtCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VrtCloneData.UpdateVariantDescriptions();
                    end;
                }
                action("Item Reference Descriptions")
                {
                    Caption = 'Item Reference Descriptions';
                    Image = UpdateDescription;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Cross Reference Descriptions action';

                    trigger OnAction()
                    var
                        VrtCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VrtCloneData.UpdateItemRefDescription();
                    end;
                }
                action(Barcodes)
                {
                    Caption = 'Barcodes';
                    Image = BarCode;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Report "NPR Update Barcodes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Barcodes action';
                }
            }
        }
        area(processing)
        {
            group("&Setup")
            {
                Caption = '&Setup';
                Image = Setup;
                action(Variety)
                {
                    Caption = 'Variety';
                    Image = ChangeLog;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variety action';
                }
                action("Field Setup")
                {
                    Caption = 'Field Setup';
                    Image = Column;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety Fields Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Field Setup action';
                }
                action(Groups)
                {
                    Caption = 'Groups';
                    Image = Allocations;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety Group";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Groups action';
                }
            }
            group(Wizard)
            {
                action("Setup Wizard")
                {
                    Caption = 'Setup Wizard';
                    Image = Setup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup Wizard action';

                    trigger OnAction()
                    var
                        VarietySetupWizard: Codeunit "NPR Variety Setup Wizard";
                    begin
                        VarietySetupWizard.Run();
                    end;
                }
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


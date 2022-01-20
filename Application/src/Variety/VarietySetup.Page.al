page 6059970 "NPR Variety Setup"
{
    Caption = 'Variety Setup';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,View,Update';
    SourceTable = "NPR Variety Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Variety Enabled"; Rec."Variety Enabled")
                {

                    ToolTip = 'Specifies the value of the Variety Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Journal Blocking"; Rec."Item Journal Blocking")
                {

                    ToolTip = 'Specifies the value of the Item Journal Blocking field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Description"; Rec."Variant Description")
                {

                    ToolTip = 'Specifies the value of the Variant Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Description 2"; Rec."Variant Description 2")
                {

                    ToolTip = 'Specifies the value of the Variant Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Variant Code From"; Rec."Create Variant Code From")
                {

                    ToolTip = 'Specifies the value of the Create Variant Code From field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Descriptions"; Rec."Custom Descriptions")
                {
                    ToolTip = 'If variant is selected on sales and purchase line item description is copied into description on sales line, purchase line, POS sales line, and variant description is copied into description 2 on sales line, purchase line and POS sales line.';
                    ApplicationArea = NPRRetail;
                }
                field("Pop up Variety Matrix"; Rec."Pop up Variety Matrix")
                {
                    ToolTip = 'If item with variants is selected on sales and purchase documents variety matrix will pop up.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant No. Series"; Rec."Variant No. Series")
                {

                    ToolTip = 'Specifies the value of the Variant Std. No. Serie field. Number series must be maximum 10 characters long.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Barcode (Item Cross Ref.)")
            {
                Caption = 'Barcode (Item Ref.)';
                field("Create Item Cross Ref. auto."; Rec."Create Item Cross Ref. auto.")
                {

                    ToolTip = 'Specifies the value of the Create Item Cross Ref. auto. field';
                    ApplicationArea = NPRRetail;
                }
                field("Barcode Type (Item Cross Ref.)"; Rec."Barcode Type (Item Cross Ref.)")
                {

                    Editable = Rec."Create Item Cross Ref. auto.";
                    ToolTip = 'Specifies the value of the Barcode Type (Item Cross Ref.) field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Cross Ref. No. Series (I)"; Rec."Item Cross Ref. No. Series (I)")
                {

                    Editable = Rec."Create Item Cross Ref. auto.";
                    ToolTip = 'If value is set, then item reference with type Bar Code will be created for Item. For details, please check an actions on Item Card - Add Missing Barcode(s).';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec."Item Cross Ref. No. Series (V)" = '' then
                            Rec."Item Cross Ref. No. Series (V)" := Rec."Item Cross Ref. No. Series (I)";
                    end;
                }
                field("Item Cross Ref. No. Series (V)"; Rec."Item Cross Ref. No. Series (V)")
                {

                    Editable = Rec."Create Item Cross Ref. auto.";
                    ToolTip = 'If value is set, then item reference with type Bar Code will be created for each Item Variant. For details, please check an actions on Item Card - Add Missing Barcode(s).';
                    ApplicationArea = NPRRetail;
                }
                field("Item Cross Ref. Description(I)"; Rec."Item Cross Ref. Description(I)")
                {

                    ToolTip = 'Specifies the value of the Item Cross Ref. Description (Item) field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Cross Ref. Description(V)"; Rec."Item Cross Ref. Description(V)")
                {

                    ToolTip = 'Specifies the value of the Item Cross Ref. Description (Variant) field';
                    ApplicationArea = NPRRetail;
                }
                field("Internal EAN No. Series"; Rec."Internal EAN No. Series")
                {

                    ToolTip = 'Specifies the value of the Internal EAN No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("External EAN No. Series"; Rec."External EAN No. Series")
                {

                    ToolTip = 'Specifies the value of the External EAN No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("EAN-Internal"; Rec."EAN-Internal")
                {

                    ToolTip = 'Specifies the value of the EAN-Internal field';
                    ApplicationArea = NPRRetail;
                }
                field("EAN-External"; Rec."EAN-External")
                {

                    ToolTip = 'Specifies the value of the EAN-External field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(View)
            {
                Caption = 'View';
                field("Hide Inactive Values"; Rec."Hide Inactive Values")
                {

                    ToolTip = 'Whether Inactive Values should be hidden in the Variant Matrix by default';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the EAN13 Internal action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the EAN13 External action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Show Original Setup action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Item Cross Reference action';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Item Variant Descriptions action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Item Cross Reference Descriptions action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Barcodes action';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Variety action';
                    ApplicationArea = NPRRetail;
                }
                action("Field Setup")
                {
                    Caption = 'Field Setup';
                    Image = Column;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety Fields Setup";

                    ToolTip = 'Executes the Field Setup action';
                    ApplicationArea = NPRRetail;
                }
                action(Groups)
                {
                    Caption = 'Groups';
                    Image = Allocations;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety Group";

                    ToolTip = 'Executes the Groups action';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Wizard)
            {
                action("Setup Wizard")
                {
                    Caption = 'Setup Wizard';
                    Image = Setup;

                    ToolTip = 'Executes the Setup Wizard action';
                    ApplicationArea = NPRRetail;

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


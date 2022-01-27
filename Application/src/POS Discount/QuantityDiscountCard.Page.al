page 6014466 "NPR Quantity Discount Card"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Multiple Price Header';
    SourceTable = "NPR Quantity Discount Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Main No."; Rec."Main No.")
                {

                    ToolTip = 'Specifies the value of the Main no. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    ToolTip = 'Specifies the value of the Modified Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Block Custom Discount"; Rec."Block Custom Discount")
                {

                    ToolTip = 'Specifies the value of the Block Custom Discount field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Description"; Rec."Item Description")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Conditions)
            {
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the value of the Starting date field';
                    ApplicationArea = NPRRetail;
                }
                field("Closing Date"; Rec."Closing Date")
                {

                    ToolTip = 'Specifies the value of the Closing Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Closing Time"; Rec."Closing Time")
                {

                    ToolTip = 'Specifies the value of the Closing Time field';
                    ApplicationArea = NPRRetail;
                }
                grid(Control6150629)
                {
                    ShowCaption = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(QuantityDiscountLine1; "NPR Quantity Discount Line")
            {
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Main no." = FIELD("Main No.");
                Visible = ActionVisible;
                Editable = DynamicEditable;
                Enabled = Rec."Main no." <> '';
                ApplicationArea = NPRRetail;

            }
        }
        area(factboxes)
        {
            part(Control6150634; "Item Invoicing FactBox")
            {
                SubPageLink = "No." = FIELD("Item No.");
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6014439),
                              "No." = FIELD("Main No.");
                ShortCutKey = 'Shift+Ctrl+D';

                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Function';
            }
            action(List)
            {
                Caption = 'List';
                Image = List;
                RunObject = Page "NPR Quantity Discount List";
                RunPageLink = "Item No." = field("Item No.");

                ToolTip = 'Executes the List action';
                ApplicationArea = NPRRetail;
            }
            separator(Separator6150623)
            {
            }
            action("Send to Retail Journal")
            {
                Caption = 'Send to Retail Journal';
                Image = SendTo;

                ToolTip = 'Executes the Send to Retail Journal action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RetailJournalMgt: Codeunit "NPR Retail Journal Code";
                begin
                    RetailJournalMgt.Quantity2RetailJnl(Rec."Item No.", Rec."Main No.", '');
                end;
            }
            action("Copy Multiple Price Discount")
            {
                Caption = 'Copy Multiple Price Discount';
                Image = CopyDocument;

                ToolTip = 'Executes the Copy Multiple Price Discount action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    QuantityDiscountHeader: Record "NPR Quantity Discount Header";
                    QuantityDiscountLine1: Record "NPR Quantity Discount Line";
                    QuantityDiscountLine: Record "NPR Quantity Discount Line";
                begin
                    if PAGE.RunModal(PAGE::"NPR Quantity Discount List", QuantityDiscountHeader) <> ACTION::LookupOK then exit;
                    QuantityDiscountLine1.Reset();
                    QuantityDiscountLine1.SetRange("Main no.", Rec."Main No.");
                    QuantityDiscountLine1.SetRange("Item No.", Rec."Item No.");
                    QuantityDiscountLine1.DeleteAll();

                    QuantityDiscountLine1.Reset();
                    QuantityDiscountLine1.SetRange("Main no.", QuantityDiscountHeader."Main No.");
                    QuantityDiscountLine1.SetRange("Item No.", QuantityDiscountHeader."Item No.");
                    if QuantityDiscountLine1.FindSet() then
                        repeat
                            QuantityDiscountLine.Init();
                            QuantityDiscountLine.TransferFields(QuantityDiscountLine1);
                            QuantityDiscountLine."Main no." := Rec."Main No.";
                            QuantityDiscountLine."Item No." := Rec."Item No.";
                            QuantityDiscountLine.Insert(true);
                        until QuantityDiscountLine1.Next() = 0;

                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DynamicEditable := CurrPage.Editable;
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange("Item No.", Rec.GetFilter("Item No."));
        if Rec.IsEmpty then begin
            Rec.Init();
            Rec."Main No." := Rec.GetFilter("Item No.");
            Rec.Insert(true);
        end;
        UpdateStatus();
        ActionVisible := true;
    end;

    var
        [InDataSet]
        ActionVisible: Boolean;
        DynamicEditable: Boolean;

    procedure UpdateStatus()
    var
        "Quantity Discount Header 2": Record "NPR Quantity Discount Header";
    begin
        "Quantity Discount Header 2".SetFilter(Status, '<>%1', Rec.Status::Balanced);
        if "Quantity Discount Header 2".FindFirst() then
            repeat
                if ("Quantity Discount Header 2"."Closing Date" < Today) or
                   (("Quantity Discount Header 2"."Closing Date" = Today) and ("Quantity Discount Header 2"."Closing Time" < Time)) then begin
                    "Quantity Discount Header 2".Validate(Status, Rec.Status::Balanced);
                    "Quantity Discount Header 2".Modify(true);
                end;
            until "Quantity Discount Header 2".Next() = 0;
    end;
}


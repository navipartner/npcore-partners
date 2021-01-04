pageextension 6014426 "NPR Customer List" extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field("NPR E-Mail"; "E-Mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the E-Mail field';
            }
            field("NPR Address"; Address)
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Address field';
            }
            field("NPR Address 2"; "Address 2")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Address 2 field';
            }
        }
        addafter("Post Code")
        {
            field("NPR City"; City)
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the City field';
            }
        }
        addafter(Contact)
        {
            field("NPR Global Dimension 1 Code"; "Global Dimension 1 Code")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
            }
            field("NPR Global Dimension 2 Code"; "Global Dimension 2 Code")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
            }
        }
        addafter("Base Calendar Code")
        {
            field(NPRAttrTextArray_01; NPRAttrTextArray[1])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 1, "No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02; NPRAttrTextArray[2])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 2, "No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03; NPRAttrTextArray[3])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 3, "No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04; NPRAttrTextArray[4])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 4, "No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05; NPRAttrTextArray[5])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 5, "No.", NPRAttrTextArray[5]);
                end;
            }
            field(NPRAttrTextArray_06; NPRAttrTextArray[6])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,6,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible06;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 6, "No.", NPRAttrTextArray[6]);
                end;
            }
            field(NPRAttrTextArray_07; NPRAttrTextArray[7])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,7,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible07;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 7, "No.", NPRAttrTextArray[7]);
                end;
            }
            field(NPRAttrTextArray_08; NPRAttrTextArray[8])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,8,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible08;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 8, "No.", NPRAttrTextArray[8]);
                end;
            }
            field(NPRAttrTextArray_09; NPRAttrTextArray[9])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,9,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible09;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 9, "No.", NPRAttrTextArray[9]);
                end;
            }
            field(NPRAttrTextArray_10; NPRAttrTextArray[10])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,10,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible10;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 10, "No.", NPRAttrTextArray[10]);
                end;
            }
        }
    }
    actions
    {
        addafter("&Customer")
        {
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send Statement as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Statement as PDF action';
                }
            }
        }
        addfirst(History)
        {
            action("NPR AuditRoll")
            {
                Caption = 'Audit Roll';
                Image = ListPage;
                ApplicationArea = All;
                ToolTip = 'Executes the Audit Roll action';
            }
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entries action';
            }
            action("NPR ItemLedgerEntries")
            {
                Caption = 'Item Ledger Entries';
                Image = ItemLedger;
                Promoted = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Item Ledger Entries action';
            }
        }
        addfirst(Creation)
        {
            action("NPR NewCustomer")
            {
                Caption = 'New Customer';
                Image = NewCustomer;
                Promoted = true;
                RunObject = Page "Customer Card";
                RunPageMode = Create;
                ApplicationArea = All;
                ToolTip = 'Executes the New Customer action';
            }
        }
        addafter("Sales Journal")
        {
            action("NPR PhoneLookup")
            {
                Caption = 'PhoneLookup';
                Image = ImportLog;
                ApplicationArea = All;
                ToolTip = 'Executes the PhoneLookup action';
            }
            action("NPR Customer Anonymization")
            {
                Caption = 'Customer Anonymization';
                Image = AbsenceCategory;
                ApplicationArea = All;
                ToolTip = 'Executes the Customer Anonymization action';

                trigger OnAction()
                var
                    Cust: Record Customer;
                    GDPRManagement: Codeunit "NPR NP GDPR Management";
                begin

                    Rec.TestField("NPR Anonymized", false);
                    Clear(GDPRManagement);
                    Clear(ReasonText);
                    if (GDPRManagement.DoAnonymization(Rec."No.", ReasonText)) then
                        if (not Confirm(Text000, false)) then
                            Error('');

                    Message(ReasonText);
                end;
            }
        }
    }

    var
        NPRAttrTextArray: array[40] of Text[100];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        NPRAttrVisible01: Boolean;
        NPRAttrVisible02: Boolean;
        NPRAttrVisible03: Boolean;
        NPRAttrVisible04: Boolean;
        NPRAttrVisible05: Boolean;
        NPRAttrVisible06: Boolean;
        NPRAttrVisible07: Boolean;
        NPRAttrVisible08: Boolean;
        NPRAttrVisible09: Boolean;
        NPRAttrVisible10: Boolean;
        Text000: Label 'All Customer Information wil be lost! Do you want to continue?';
        ReasonText: Text;


    trigger OnAfterGetRecord()
    begin
        NPRAttrManagement.GetMasterDataAttributeValue(NPRAttrTextArray, DATABASE::Customer, "No.");
        NPRAttrEditable := CurrPage.Editable();
    end;


    trigger OnOpenPage()

    begin
        NPRAttrManagement.GetAttributeVisibility(DATABASE::Customer, NPRAttrVisibleArray);
        NPRAttrVisible01 := NPRAttrVisibleArray[1];
        NPRAttrVisible02 := NPRAttrVisibleArray[2];
        NPRAttrVisible03 := NPRAttrVisibleArray[3];
        NPRAttrVisible04 := NPRAttrVisibleArray[4];
        NPRAttrVisible05 := NPRAttrVisibleArray[5];
        NPRAttrVisible06 := NPRAttrVisibleArray[6];
        NPRAttrVisible07 := NPRAttrVisibleArray[7];
        NPRAttrVisible08 := NPRAttrVisibleArray[8];
        NPRAttrVisible09 := NPRAttrVisibleArray[9];
        NPRAttrVisible10 := NPRAttrVisibleArray[10];
    end;
}

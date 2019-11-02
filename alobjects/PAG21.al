pageextension 6014421 pageextension6014421 extends "Customer Card" 
{
    // PN1.00/MH/20140725  NAV-AddOn: PDF2NAV
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page).
    // NPR70.00.02.01/MH/20150216  CASE 204110 Removed Loyalty Module
    // MAG1.08/MHA /20150311  CASE 206395 Added Webshop Group and function SetMagentoVisible()
    // MAG1.17/MHA /20150622  CASE 215533 Magento related NaviConnect Setup moved to Magento Setup
    // NPR4.11/TSA /20150623  CASE 209946 - Shortcut Attributes
    // NPR9   /JDH /20151119  CASE 225607 Merge to NAV 2016
    // PN1.08 /TTH /10122015  CASE 229069 Added Customer Statement Sending
    // PN1.08 /MHA /20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10 /MHA /20160314  CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.23/TS  /20160524  CASE 242388 Added Action Member Card
    // NPR5.23/TS  /20160603  CASE 243212 Promoted Action Alternative nummer
    // NPR5.23/TS  /20160608  CASE 243611 Removed Actions
    // NPR5.25/MMV /20160621  CASE 233533 Added action "PrintShippingLabel"
    // MAG2.00/MHA /20160525  CASE 240005 Magento Integration
    // NPR5.26/OSFI/20160811  CASE 246167 Added Action "POS Info"
    // MAG2.01/MHA /20160525  CASE 240005 Magento function removed to better support extensions: SetMagentoVisible()
    // NPR5.29/TJ  /20170113  CASE 262797 Renamed actions Vareposter to ItemLedgerEntries, Alternativ Nummer to AlternativNo
    //   - Moved code from actions ItemLedgerEntries, AlternativNo and PrintShippingLabel into subscriber functions
    //   - Removed functions used as separators (--- NC)
    // NPR5.30/THRO/20170203 CASE 263182 Added action SendSMS
    // NPR5.30/BHR /20170217 CASE 262923 Change image for action'Reparation' Open list instead of card.
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.33/BHR /20172526 CASE 277663 Added action Audit Roll
    // NPR5.33/TR  /20170627 CASE 278820 Added Customer."Name 2" to General group.
    // NPR5.38/BR  /20171117 CASE 295255 Added Action POS Entries
    // NPR5.38/KENU/20170815 CASE 282631 Added field "Tax Area Code" and "Tax Liable" to "Invoicing"
    // NPR5.42/THRO/20180516 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.48/TSA /20181218 CASE 320424 Added "Magento Shipping Group", "Magento Payment Group", "Magento Store Code"
    // MAG2.20/MHA /20190426 CASE 320423 Added Magento Version visibility control
    // NPR5.52/ZESO/20190925 CASE 358656 Added Fields Anonymized,Anonymized Date,To Anonymize and Customer Anonymization functionality.
    layout
    {
        addafter(Name)
        {
            field("Name 2";"Name 2")
            {
                Importance = Additional;
            }
        }
        addafter(AdjProfitPct)
        {
            field("To Anonymize";"To Anonymize")
            {
                Editable = ToAnonymizeEditable;
            }
            field(Anonymized;Anonymized)
            {
            }
            field("Anonymized Date";"Anonymized Date")
            {
            }
        }
        addafter("Disable Search by Name")
        {
            field(NPRAttrTextArray_01;NPRAttrTextArray[1])
            {
                CaptionClass = '6014555,18,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 1, "No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02;NPRAttrTextArray[2])
            {
                CaptionClass = '6014555,18,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 2, "No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03;NPRAttrTextArray[3])
            {
                CaptionClass = '6014555,18,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 3, "No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04;NPRAttrTextArray[4])
            {
                CaptionClass = '6014555,18,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 4, "No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05;NPRAttrTextArray[5])
            {
                CaptionClass = '6014555,18,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 5, "No.", NPRAttrTextArray[5]);
                end;
            }
        }
        addafter("Address & Contact")
        {
            group(Magento)
            {
                Caption = 'Magento';
                field("Magento Display Group";"Magento Display Group")
                {
                }
                field("Magento Store Code";"Magento Store Code")
                {
                    Visible = (MagentoVersion >= 2);
                }
                field("Magento Shipping Group";"Magento Shipping Group")
                {
                    Visible = (MagentoVersion >= 2);
                }
                field("Magento Payment Group";"Magento Payment Group")
                {
                    Visible = (MagentoVersion >= 2);
                }
            }
            group("Extra Fields")
            {
                Caption = 'Extra Fields';
                field(NPRAttrTextArray_06;NPRAttrTextArray[6])
                {
                    CaptionClass = '6014555,18,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 6, "No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07;NPRAttrTextArray[7])
                {
                    CaptionClass = '6014555,18,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 7, "No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08;NPRAttrTextArray[8])
                {
                    CaptionClass = '6014555,18,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 8, "No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09;NPRAttrTextArray[9])
                {
                    CaptionClass = '6014555,18,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 9, "No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10;NPRAttrTextArray[10])
                {
                    CaptionClass = '6014555,18,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 10, "No.", NPRAttrTextArray[10]);
                    end;
                }
            }
        }
        addafter("VAT Registration No.")
        {
            field("Tax Liable";"Tax Liable")
            {
            }
            field("Tax Area Code";"Tax Area Code")
            {
            }
        }
        addafter("Prepayment %")
        {
            field("Document Processing";"Document Processing")
            {
            }
        }
    }
    actions
    {
        addfirst(Navigation)
        {
            group("Retail Documents")
            {
                Caption = 'Retail Documents';
                action("Selection Contract")
                {
                    Caption = 'Selections contracts';
                    Image = Document;
                    RunObject = Page "Retail Document Header";
                    RunPageLink = "Document Type"=CONST("Selection Contract"),
                                  "Customer No."=FIELD("No."),
                                  "Customer Type"=CONST(Alm);
                }
            }
            group(Retail)
            {
                Caption = 'Retail';
                action(Brugtvarer)
                {
                    Caption = 'Used Goods';
                    Image = "Action";
                    RunObject = Page "Used Goods Reg. Card";
                    RunPageLink = "Purchased By Customer No."=FIELD("No.");
                }
                action(ItemLedgerEntries)
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                }
                action(AuditRoll)
                {
                    Caption = 'Audit Roll';
                    Image = ListPage;
                }
                action(AlternativeNo)
                {
                    Caption = 'Alternative No.';
                    Image = "Action";
                    Promoted = true;
                }
                action(Reparation)
                {
                    Caption = 'Reparation';
                    Image = ServiceZone;
                    RunObject = Page "Customer Repair List";
                    RunPageLink = "Customer No."=FIELD("No."),
                                  "Customer Type"=CONST(Ordinary);
                }
                action("Member Cards")
                {
                    Caption = 'Member Cards';
                    Image = Card;
                    RunObject = Page "Member Card Issued Cards";
                    RunPageLink = "Customer No"=FIELD("No.");
                }
                action(PrintShippingLabel)
                {
                    Caption = 'Shipping Label';
                    Image = PrintCheck;
                }
            }
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send Statement as PDF';
                    Image = SendEmailPDF;
                }
            }
        }
        addafter(CustomerReportSelections)
        {
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = Info;
                RunObject = Page "POS Info Links";
                RunPageLink = "Table ID"=CONST(18),
                              "Primary Key"=FIELD("No.");
            }
        }
        addafter("Item &Tracking Entries")
        {
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
            }
        }
        addafter(Documents)
        {
            group(SMS)
            {
                Caption = 'SMS';
                action(SendSMS)
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                }
            }
        }
        addafter(PaymentRegistration)
        {
            action("Customer Anonymization")
            {
                Caption = 'Customer Anonymization';
                Ellipsis = true;
                Image = AbsenceCategory;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    GDPRManagement: Codeunit "NP GDPR Management";
                begin
                    //-NPR5.52 [358656]
                    TestField(Anonymized,false);
                    TestField("To Anonymize",true);
                    if (GDPRManagement.DoAnonymization("No.",ReasonText)) then
                      if (not Confirm(Text000,false) )then
                        Error('');


                    Message(ReasonText);
                    //+NPR5.52 [358656]
                end;
            }
        }
    }

    var
        DynamicEditable: Boolean;

    var
        NPRAttrTextArray: array [40] of Text[100];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array [40] of Boolean;
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
        MagentoVersion: Decimal;

    var
        ReasonText: Text;
        Text000: Label 'All Customer Information wil be lost! Do you want to continue?';
        ToAnonymizeEditable: Boolean;
        UserSetup: Record "User Setup";


    //Unsupported feature: Code Modification on "OnAfterGetRecord".

    //trigger OnAfterGetRecord()
    //>>>> ORIGINAL CODE:
    //begin
        /*
        ActivateFields;
        StyleTxt := SetStyle;
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        ActivateFields;
        StyleTxt := SetStyle;

        //-NPR4.11
        NPRAttrManagement.GetMasterDataAttributeValue (NPRAttrTextArray, DATABASE::Customer, "No.");
        NPRAttrEditable := CurrPage.Editable ();
        //+NPR4.11


        //-NPR5.52 [358656]
        if UserSetup.Get(UserId) then
          if UserSetup."Anonymize Customers" then
            ToAnonymizeEditable := true
          else
            ToAnonymizeEditable := false;

        //-NPR5.52 [358656]
        */
    //end;


    //Unsupported feature: Code Modification on "OnInit".

    //trigger OnInit()
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
        /*
        FoundationOnly := ApplicationAreaMgmtFacade.IsFoundationEnabled;

        SetCustomerNoVisibilityOnFactBoxes;
        #4..8
        CaptionTxt := CurrPage.Caption;
        SetCaption(CaptionTxt);
        CurrPage.Caption(CaptionTxt);
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        #1..11

        //-NPR5.52 [358656]
        ToAnonymizeEditable := false;
        //+NPR5.52 [358656]
        */
    //end;


    //Unsupported feature: Code Modification on "OnOpenPage".

    //trigger OnOpenPage()
    //>>>> ORIGINAL CODE:
    //begin
        /*
        ActivateFields;

        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled;
        #4..8
        if FoundationOnly then
          CurrPage.PriceAndLineDisc.PAGE.InitPage(false);

        ShowCharts := "No." <> '';
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        #1..11
        //-NPR4.11
        NPRAttrManagement.GetAttributeVisibility (DATABASE::Customer, NPRAttrVisibleArray);
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

        NPRAttrEditable := CurrPage.Editable ();
        //+NPR4.11
        //-MAG2.20 [320423]
        SetMagentoVersion();
        //+MAG2.20 [320423]

        ShowCharts := "No." <> '';

        //-NPR5.52 [358656]
        if UserSetup.Get(UserId) then
          if UserSetup."Anonymize Customers" then
            ToAnonymizeEditable := true
          else
            ToAnonymizeEditable := false;

        //-NPR5.52 [358656]
        */
    //end;

    local procedure SetMagentoVersion()
    var
        MagentoSetup: Record "Magento Setup";
    begin
        //-MAG2.20 [320423]
        if not MagentoSetup.Get then
          exit;

        case MagentoSetup."Magento Version" of
          MagentoSetup."Magento Version"::"1":
            MagentoVersion := 1;
          MagentoSetup."Magento Version"::"2":
            MagentoVersion := 2;
        end;
        //+MAG2.20 [320423]
    end;
}


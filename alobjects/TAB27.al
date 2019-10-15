tableextension 6014427 tableextension6014427 extends Item 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields with Description starting NPR7.100.000
    //                                        Added Keys : Group sale,Item Group,Vendor No. for report 6014400
    //                                        Added Assembly BOM to FieldGroups
    //                                        Added Code with tags NPR7.100.000
    // MAG1.00/MH/20150113  CASE 199932 Upgraded Magento Integration from WEB1.00.
    // NPR7.100.001/BHR/20150120 CASE 203485 Add field 6014630 'Blocked on Pos'
    // MAG1.01/MH/20150201  CASE 199932 Renamed field 6060003, 6060019 and 6059820 to resemble Magento naming.
    // MAG1.02/MH/20150202  CASE 199932 Added Magento Item Hooks.
    // MAG1.04/MH/20150206  CASE 199932 WebVariant Maintenance moved to MagentoHooks.
    // NPR70.00.03.03/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // MAG1.05/MH/20150224  CASE 199932 Updated WebVariant:
    //                                     - Changed field 6059859 "Configurable Item" [Boolean] to "WebVariant Type" [Option]
    //                                     - Changed field 6059860 "Configurable Item No." to "WebVariant Main Item No."
    //                                     - Changed field 6059861 "Web Variants" to "WebVariant Count"
    // VRT1.00/JDH/20150225 CASE 201022 Added Variety fields 6059970-6059982 + changed lookup on field 6014609 to use variant table
    // NPR4.01/JDH/20150309 CASE 201022 Removed reference to table item fabrication, to align NAV 62 with 71
    // MAG1.12/MH/20150407  CASE 210712 Updated captions
    // NPR4.14/JDH/20150831 CASE 221837 Removed unused variables
    // MAG1.21/MHA/20151120 CASE 227734 Deleted WebVariant fields [MAG1.05] and Field 6060022 Meta Keywords
    // NPR4.18/MMV/20151222 CASE 225584 Added field 6014513
    // MAG1.22/TR/20160420  CASE 238563 Added New Field Custom Options
    // MAG1.22/MHA/20160427 CASE 240257 MagentoHooks removed and converted to EventSubscriber: OnInsert(), OnModify() and OnDelete()
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX Solution
    // NPR5.25/BR  /20160719 CASE 246088 Added field 6060054 Item Status
    // NPR5.25/BHR/20160720 CASE 247022 Connenter code to allow item groups to servive items.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.26/MHA /20160810 CASE 248288 Deleted unused fields
    // NPR5.27/MMV /20161011 CASE 254486 Changed tablerelation from AltNo to Item cross ref on field 6014410 - "Label Barcode".
    // NPR5.29/JDH /20161222 CASE 261631 Added Label Lookup functionality
    // NPR5.29/MMV /20170125  CASE 264560 Added validation for "Label Barcode".
    // NPR5.30/MMV /20170202  CASE 265190 Moved "Label Barcode" validation to event subscriber.
    // NPR5.30/TJ  /20170119  CASE 263908 Restored standard code back in Inventory Posting Group - OnValidate()
    // NPR5.30/TJ  /20170602  CASE 263917 Removed code at Label Barcode - OnLookup and updated TableRelation. Properties ValidateTableRelation and TestTableRelation restored to default values.
    //                                    New field Create Alt. No. automatic
    // NPR5.33/BHR /20170629  CASE 280196 Delete unused Fields
    // MAG2.07/MHA /20170912  CASE 289369 Increased length of field 6060021 "Meta Title" from 50 to 70
    // NPR5.38/MHA /20180104  CASE 299272 Added fields 6014635 "Sale Blocked" and 6014640 "Purchase Blocked"
    // NPR5.40/MHA /20180214  CASE 288039 Added flowfield 6014506 "Has Accessories"
    // NPR5.42/MMV /20180504  CASE 297569 Added field 6014641
    // NPR5.43/RA  /20180419  CASE 311886 On field 6014502 added option "B+"
    // NPR5.44/TS  /20180713  CASE 321708 Retail Item List added as Drilldown and Lookup again
    // NPR5.47/JDH /20180913  CASE 327541 Changed field length of "Variety 1 Table" (and 2+3+4) to 40 characters
    // NPR5.48/MHA /20181105  CASE 334212 Added fields 6014435 "Last Changed at", 6014440 "Last Changed by"
    // NPR5.48/MHA /20181109  CASE 334922 Added field 6151125 "Item AddOn No."
    // NPR5.49/ZESO/20190318  CASE 349061 Changed ObsoleteState of Product Group Code Property back to Pending.
    // MAG2.22/MHA /20190614  CASE 358258 Extended field 6151440 "Meta Title" from 70 to 100
    // MAG2.22/MHA /20190625  CASE 359285 Added field 6151500 "Magento Picture Variety Type"
    // NPR5.51/BHR /20190730  CASE 361929 Increase size of fiels season from 3 to 10
    // NPR5.51/BHR /20190801  CASE 363493 Set property Width of Field Description to 50
    // NPR5.51/ZESO/20190828  CASE 365796 Added field 6014642 Shelf Label Type
    LookupPageID = "Retail Item List";
    DrillDownPageID = "Retail Item List";
    fields
    {
        modify(Description)
        {
            Width = 50;
        }
        field(6014400; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            Description = 'NPR7.100.000';
            TableRelation = "Item Group";
        }
        field(6014401; "Group sale"; Boolean)
        {
            Caption = 'Various item sales';
            Description = 'NPR7.100.000';
        }
        field(6014408;Season;Code[10])
        {
            Caption = 'Season';
            Description = 'NPR7.100.000';
        }
        field(6014409; "Create Alt. No. Automatic"; Boolean)
        {
            CalcFormula = Lookup ("Variety Setup"."Create Alt. No. automatic");
            Caption = 'Create Alt. No. Automatic';
            Description = 'NPR5.30';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6014410; "Label Barcode"; Code[20])
        {
            Caption = 'Label barcode';
            Description = 'NPR7.100.000';
            TableRelation = IF ("Create Alt. No. Automatic" = CONST (false)) "Item Cross Reference"."Cross-Reference No." WHERE ("Cross-Reference Type" = CONST ("Bar Code"),
                                                                                                                              "Item No." = FIELD ("No."),
                                                                                                                              "Cross-Reference No." = FILTER (<> ''),
                                                                                                                              "Variant Code" = CONST (''))
            ELSE
            IF ("Create Alt. No. Automatic" = CONST (true)) "Alternative No."."Alt. No." WHERE (Type = CONST (Item),
                                                                                                                                                                                                                    Code = FIELD ("No."),
                                                                                                                                                                                                                    "Alt. No." = FILTER (<> ''),
                                                                                                                                                                                                                    "Variant Code" = CONST (''));
        }
        field(6014418; "Explode BOM auto"; Boolean)
        {
            Caption = 'Auto-explode BOM';
            Description = 'NPR7.100.000';
        }
        field(6014419; "Guarantee voucher"; Boolean)
        {
            Caption = 'Guarantee voucher';
            Description = 'NPR7.100.000';
        }
        field(6014424; "Cannot edit unit price"; Boolean)
        {
            Caption = 'Can''t edit unit price';
            Description = 'NPR7.100.000';
        }
        field(6014428; "Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            Description = 'NPR7.100.000';
        }
        field(6014435; "Last Changed at"; DateTime)
        {
            Caption = 'Last Changed at';
            Description = 'NPR5.48';
        }
        field(6014440; "Last Changed by"; Code[50])
        {
            Caption = 'Last Changed by';
            Description = 'NPR5.48';
        }
        field(6014500; "Second-hand number"; Code[20])
        {
            Caption = 'Second-hand number';
            Description = 'NPR7.100.000';
        }
        field(6014502; Condition; Option)
        {
            Caption = 'Condition';
            Description = 'NPR7.100.000';
            OptionCaption = 'New,Mint,Mint boxed,A,B,C,D,E,F,B+';
            OptionMembers = New,Mint,"Mint boxed",A,B,C,D,E,F,"B+";
        }
        field(6014503; "Second-hand"; Boolean)
        {
            Caption = 'Second-hand';
            Description = 'NPR7.100.000';
        }
        field(6014504; "Guarantee Index"; Option)
        {
            Caption = 'Guarantee Index';
            Description = 'NPR7.100.000';
            OptionCaption = ' ,Move to Warranty';
            OptionMembers = " ","Flyt til garanti kar.";
        }
        field(6014506; "Has Accessories"; Boolean)
        {
            CalcFormula = Exist ("Accessory/Spare Part" WHERE (Code = FIELD ("No.")));
            Caption = 'Has Accessories';
            Description = 'NPR5.40';
            FieldClass = FlowField;
        }
        field(6014508; "Insurrance category"; Code[50])
        {
            Caption = 'Insurance Section';
            Description = 'NPR7.100.000';
            TableRelation = "Insurance Category";
        }
        field(6014509; "Item Brand"; Code[10])
        {
            Caption = 'Item brand';
            Description = 'NPR7.100.000';
        }
        field(6014512; "No Print on Reciept"; Boolean)
        {
            Caption = 'No Print on Reciept';
            Description = 'NPR7.100.000';
        }
        field(6014513; "Print Tags"; Text[100])
        {
            Caption = 'Print Tags';
        }
        field(6014609; "Has Variants"; Boolean)
        {
            CalcFormula = Exist ("Item Variant" WHERE ("Item No." = FIELD ("No.")));
            Caption = 'Has Variants';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014625; "Std. Sales Qty."; Decimal)
        {
            Caption = 'Std. Sales Qty.';
            Description = 'NPR7.100.000';
        }
        field(6014630; "Blocked on Pos"; Boolean)
        {
            Caption = 'Blocked on Pos';
            Description = 'NPR7.100.001';
        }
        field(6014635; "Sale Blocked"; Boolean)
        {
            Caption = 'Sale Blocked';
            Description = 'NPR5.38';
        }
        field(6014640; "Purchase Blocked"; Boolean)
        {
            Caption = 'Purchase Blocked';
            Description = 'NPR5.38';
        }
        field(6014641; "Custom Discount Blocked"; Boolean)
        {
            Caption = 'Custom Discount Blocked';
            Description = 'NPR5.42 [297569]';
        }
        field(6014642;"Shelf Label Type";Code[50])
        {
            Caption = 'Shelf Label Type';
            Description = 'NPR5.51';
        }
        field(6059784; "Ticket Type"; Code[10])
        {
            Caption = 'Ticket Type';
            Description = 'NPR7.100.000,Ticket';
            TableRelation = "TM Ticket Type";
        }
        field(6059970; "Variety 1"; Code[10])
        {
            Caption = 'Variety 1';
            Description = 'VRT1.00';
            TableRelation = Variety;
        }
        field(6059971; "Variety 1 Table"; Code[40])
        {
            Caption = 'Variety 1 Table';
            Description = 'VRT1.00';
            TableRelation = "Variety Table".Code WHERE (Type = FIELD ("Variety 1"));
        }
        field(6059973; "Variety 2"; Code[10])
        {
            Caption = 'Variety 2';
            Description = 'VRT1.00';
            TableRelation = Variety;
        }
        field(6059974; "Variety 2 Table"; Code[40])
        {
            Caption = 'Variety 2 Table';
            Description = 'VRT1.00';
            TableRelation = "Variety Table".Code WHERE (Type = FIELD ("Variety 2"));
        }
        field(6059976; "Variety 3"; Code[10])
        {
            Caption = 'Variety 3';
            Description = 'VRT1.00';
            TableRelation = Variety;
        }
        field(6059977; "Variety 3 Table"; Code[40])
        {
            Caption = 'Variety 3 Table';
            Description = 'VRT1.00';
            TableRelation = "Variety Table".Code WHERE (Type = FIELD ("Variety 3"));
        }
        field(6059979; "Variety 4"; Code[10])
        {
            Caption = 'Variety 4';
            Description = 'VRT1.00';
            TableRelation = Variety;
        }
        field(6059980; "Variety 4 Table"; Code[40])
        {
            Caption = 'Variety 4 Table';
            Description = 'VRT1.00';
            TableRelation = "Variety Table".Code WHERE (Type = FIELD ("Variety 4"));
        }
        field(6059981; "Cross Variety No."; Option)
        {
            Caption = 'Cross Variety No.';
            Description = 'VRT1.00';
            OptionCaption = 'Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = Variety1,Variety2,Variety3,Variety4;
        }
        field(6059982; "Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            Description = 'VRT1.00';
            TableRelation = "Variety Group";
        }
        field(6060054; "Item Status"; Code[10])
        {
            Caption = 'Item Status';
            Description = 'NPR5.25';
            TableRelation = "Item Status";
        }
        field(6151125; "Item AddOn No."; Code[20])
        {
            Caption = 'Item AddOn No.';
            Description = 'NPR5.48';
            TableRelation = "NpIa Item AddOn";
        }
        field(6151400; "Magento Item"; Boolean)
        {
            Caption = 'Magento Item';
            Description = 'MAG2.00';
        }
        field(6151405; "Magento Status"; Option)
        {
            BlankZero = true;
            Caption = 'Magento Status';
            Description = 'MAG2.00';
            InitValue = Active;
            OptionCaption = ',Active,Inactive';
            OptionMembers = ,Active,Inactive;
        }
        field(6151410; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            Description = 'MAG2.00';
            TableRelation = "Magento Attribute Set";
        }
        field(6151415; "Magento Description"; BLOB)
        {
            Caption = 'Magento Description';
            Description = 'MAG2.00';
        }
        field(6151420; "Magento Name"; Text[250])
        {
            Caption = 'Magento Name';
            Description = 'MAG2.00';
        }
        field(6151425; "Magento Short Description"; BLOB)
        {
            Caption = 'Magento Short Description';
            Description = 'MAG2.00';
        }
        field(6151430; "Magento Brand"; Code[20])
        {
            Caption = 'Magento Brand';
            Description = 'MAG2.00';
            TableRelation = "Magento Brand";
        }
        field(6151435; "Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            Description = 'MAG2.00';
        }
        field(6151440; "Meta Title"; Text[100])
        {
            Caption = 'Meta Title';
            Description = 'MAG2.00,MAG2.07,MAG2.22';
        }
        field(6151445; "Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            Description = 'MAG2.00';
        }
        field(6151450; "Product New From"; Date)
        {
            Caption = 'Product New From';
            Description = 'MAG2.00';
        }
        field(6151455; "Product New To"; Date)
        {
            Caption = 'Product New To';
            Description = 'MAG2.00';
        }
        field(6151460; "Special Price"; Decimal)
        {
            Caption = 'Special Price';
            Description = 'MAG2.00';
        }
        field(6151465; "Special Price From"; Date)
        {
            Caption = 'Special Price From';
            Description = 'MAG2.00';
        }
        field(6151470; "Special Price To"; Date)
        {
            Caption = 'Special Price To';
            Description = 'MAG2.00';
        }
        field(6151475; "Featured From"; Date)
        {
            Caption = 'Featured From';
            Description = 'MAG2.00';
        }
        field(6151480; "Featured To"; Date)
        {
            Caption = 'Featured To';
            Description = 'MAG2.00';
        }
        field(6151485; Backorder; Boolean)
        {
            Caption = 'Backorder';
            Description = 'MAG2.00';
        }
        field(6151490; "Display Only"; Boolean)
        {
            Caption = 'Display Only';
            Description = 'MAG2.00';
        }
        field(6151495; "Custom Options"; Integer)
        {
            CalcFormula = Count ("Magento Item Custom Option" WHERE ("Item No." = FIELD ("No."),
                                                                    Enabled = CONST (true)));
            Caption = 'Custom Options';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151500;"Magento Picture Variety Type";Option)
        {
            Caption = 'Magento Picture Variety Type';
            Description = 'MAG2.22';
            OptionCaption = 'None,Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = "None","Variety 1","Variety 2","Variety 3","Variety 4";
        }
    }
    keys
    {
        key(Key1; "Group sale", "Item Group")
        {
        }
        key(Key2; "Primary Key Length")
        {
        }
    }

    //Unsupported feature: Property Modification (Fields) on "DropDown(FieldGroup 1)".

}


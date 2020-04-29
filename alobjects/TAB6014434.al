table 6014434 "Touch Screen - Menu Lines"
{
    // NPR4.04/TS/20150316  CASE 205332 Change Option Value from Form to Page in field Line Type
    // NPR4.10/VB/20150601 CASE 213003 Added field Icon Class
    // NPR4.13/VB/20150723 CASE 213003 Added field Hide on Handheld
    // NPR4.14/VB/20150909 CASE 222539 Field "Hide on Handheld" replaced with field "Show Behavior" (replace is intentional, as meaning of the old field is extended)
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.46/BHR /20180824 CASE 322752 Replace record Object to Allobj
    // NPR5.48/TJ  /20181106 CASE 331261 Text line and Description fields can now hold more characters from item group description
    // NPR5.48/JDH /20181108 CASE 334560 Replaced last remains of object type "Form" with "Page"
    // TM1.39/THRO/20181126 CASE 334644 Remove unused Codeunit 1 variable

    Caption = 'Touch Screen - Menu Lines';
    LookupPageID = "Touch Screen - Setup";

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'Line No.';
            Description = 'Unique number for dynamic';
        }
        field(2;"Only Visible To";Code[20])
        {
            Caption = 'User';
            Description = 'Allowed to use only by user > this option number';
            Numeric = false;
            TableRelation = "Salesperson/Purchaser".Code;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(3;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Item Group,User,Item Functions,Login,Sale Functions,Payment Functions,Sale Form,Customer Functions,Payment Form,Temp,PaymentType,G/L Account,Comment,Insurance,Keyboard,Discount,Prints,Reports,Customer';
            OptionMembers = Item,"Item Group",User,"Item Functions",Login,"Sale Functions","Payment Functions","Sale Form","Customer Functions","Payment Form",Temp,PaymentType,"G/L Account",Comment,Insurance,Keyboard,Discount,Prints,Reports,Customer;
        }
        field(4;"Config No.";Code[30])
        {
            Caption = 'Config No.';
        }
        field(5;"Text Line 1";Text[50])
        {
            Caption = 'Text Line 1';
            Description = 'First text line';
        }
        field(6;"Text Line 2";Text[50])
        {
            Caption = 'Text Line 2';
            Description = 'Second text line';
        }
        field(7;Description;Text[50])
        {
            Caption = 'Description';
            Description = 'Description of the button';
        }
        field(8;Bitmap;Text[250])
        {
            Caption = 'Image Path';
            Description = 'Placement of bitmap for object';
        }
        field(9;Level;Integer)
        {
            Caption = 'Level';
            Description = 'Submenu level of button. 0 = Toplevel, 1 = sublevel 1 etc...';
        }
        field(10;Enabled;Boolean)
        {
            Caption = 'Enabled';
            Description = 'Overruling of "Only visible to" if FALSE';
            InitValue = true;
        }
        field(11;Terminal;Code[20])
        {
            Caption = 'Register';
            Description = '0 = ALL, 1 = kasse 1, etc...';
            TableRelation = Register."Register No.";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(12;"Register Type";Code[10])
        {
            Caption = 'Cash Register Type';
            TableRelation = "Register Types";
        }
        field(13;"Filter No.";Code[50])
        {
            Caption = 'Filter No.';
            Description = 'Only selection on No.';

            trigger OnLookup()
            var
                int1: Integer;
            begin
                // VARE
                if (Type = Type::Item) then begin
                end;

                // PERSONALE
                if Type = Type::User then
                      if PAGE.RunModal(PAGE::"Salespersons/Purchasers", Salesperson) = ACTION::LookupOK then begin
                        Validate("Filter No.", Salesperson.Code);
                      end;

                // FUNKTIONER:LOGIN
                if Type = Type::Login then begin
                      "TS Functions".Reset;
                      "TS Functions".SetFilter(Type, '%1|%2', "TS Functions".Type::Login, "TS Functions".Type::Generel);
                      if PAGE.RunModal(6014471, "TS Functions") = ACTION::LookupOK then begin
                        Validate("Filter No.", "TS Functions".Code);
                      end;
                end;

                // FUNKTIONER: EKSP
                if Type in [Type::"Sale Functions", Type::"Sale Form"] then begin
                  case "Line Type" of
                    "Line Type"::Item :
                      if PAGE.RunModal(PAGE::"Item List", Item) = ACTION::LookupOK then begin
                        Validate("Filter No.", Item."No.");
                      end;
                    "Line Type"::"Item Group" :
                      begin
                        if PAGE.RunModal(PAGE::"Item Group Tree", "Item Group") = ACTION::LookupOK then
                          Validate("Filter No.", "Item Group"."No.");
                      end;
                    "Line Type"::Internal :
                       begin
                         "TS Functions".Reset;
                         "TS Functions".SetFilter(Type, '%1|%2', "TS Functions".Type::Sale,
                                                  "TS Functions".Type::Generel);
                         if PAGE.RunModal(6014471, "TS Functions") = ACTION::LookupOK then
                           Validate("Filter No.", "TS Functions".Code);
                       end;
                    "Line Type"::Hyperlink :;
                    "Line Type"::Report:
                       begin
                         Objects.Reset;
                //-NPR5.46 [322752]
                //         Objects.SETFILTER(Type, '=%1', Objects.Type::Report);
                //           IF PAGE.RUNMODAL(358, Objects) = ACTION::LookupOK THEN
                //             VALIDATE("Filter No.", FORMAT(Objects.ID));
                          Objects.SetFilter("Object Type", '=%1', Objects."Object Type"::Report);
                           if PAGE.RunModal(696, Objects) = ACTION::LookupOK then
                             Validate("Filter No.", Format(Objects."Object ID"));
                //+NPR5.46 [322752]
                       end;
                    "Line Type"::"Codeunit(sale)",
                    "Line Type"::"Codeunit(line)" :
                       begin
                         Objects.Reset;
                //-NPR5.46 [322752]
                //         Objects.SETFILTER(Type, '=%1', Objects.Type::Codeunit);
                //           IF PAGE.RUNMODAL(358, Objects) = ACTION::LookupOK THEN
                //             VALIDATE("Filter No.", FORMAT(Objects.ID));
                         Objects.SetFilter("Object Type", '=%1', Objects."Object Type"::Codeunit);
                           if PAGE.RunModal(696, Objects) = ACTION::LookupOK then
                             Validate("Filter No.", Format(Objects."Object ID"));
                //+NPR5.46 [322752]
                       end;
                    "Line Type"::Page:
                       begin
                         Objects.Reset;
                //-NPR5.46 [322752]
                //         Objects.SETFILTER(Type, '=%1', Objects.Type::"2");
                //           IF PAGE.RUNMODAL(358, Objects) = ACTION::LookupOK THEN
                //             VALIDATE("Filter No.", FORMAT(Objects.ID));
                         //-NPR5.48 [334560]
                         //Objects.SETFILTER("Object Type", '=%1', Objects."Object Type"::"2");
                         Objects.SetRange("Object Type", Objects."Object Type"::Page);
                         //+NPR5.48 [334560]

                           if PAGE.RunModal(696, Objects) = ACTION::LookupOK then
                             Validate("Filter No.", Format(Objects."Object ID"));
                //+NPR5.46 [322752]
                       end;
                    "Line Type"::Customer:
                      begin
                        if PAGE.RunModal(PAGE::"Customer List",Customer) = ACTION::LookupOK then
                          Validate("Filter No.", Customer."No.");
                      end;
                  end;
                end;

                // FORSIKRING
                if Type = Type::Insurance then begin
                      if PAGE.RunModal(PAGE::"Insurance Companies", Forsikring) = ACTION::LookupOK then
                        Validate("Filter No.", Forsikring.Code);
                end;

                // FUNKTIONER: BETALING
                if Type = Type::"Payment Functions" then begin
                      "TS Functions".Reset;
                      "TS Functions".SetFilter(Type, '%1|%2', "TS Functions".Type::Payment, "TS Functions".Type::Generel);
                      if PAGE.RunModal(6014471, "TS Functions") = ACTION::LookupOK then begin
                        Validate("Filter No.", "TS Functions".Code);
                      end;
                end;

                // BETALINGSVALG
                if Type = Type::PaymentType then begin
                      Betalingsvalg.Reset;
                      Betalingsvalg.SetRange("Via Terminal", false);
                      //Betalingsvalg.SETFILTER("Processing Type", '<>%1', Betalingsvalg."Processing Type"::"Terminal Card");
                      if PAGE.RunModal(PAGE::"Payment Type - Register", Betalingsvalg) = ACTION::LookupOK then begin
                        Validate("Filter No.", Betalingsvalg."No.");
                      end;
                end;

                // CUSTOMER
                if Type = Type::"Customer Functions" then begin
                      case "Line Type" of
                        "Line Type"::Internal :
                           begin
                             "TS Functions".Reset;
                             "TS Functions".SetFilter(Type, '%1|%2', "TS Functions".Type::Sale,
                                                      "TS Functions".Type::Generel);
                             if PAGE.RunModal(6014471, "TS Functions") = ACTION::LookupOK then
                               Validate("Filter No.", "TS Functions".Code);
                           end;
                        "Line Type"::Page:
                           begin
                             Objects.Reset;
                //-NPR5.46 [322752]
                //             Objects.SETFILTER(Type, '=%1', Objects.Type::"2");
                //               IF PAGE.RUNMODAL(358, Objects) = ACTION::LookupOK THEN
                //                 VALIDATE("Filter No.", FORMAT(Objects.ID));
                             //-NPR5.48 [334560]
                             //Objects.SETFILTER("Object Type", '=%1', Objects."Object Type"::"2");
                             Objects.SetRange("Object Type", Objects."Object Type"::Page);
                             //+NPR5.48 [334560]
                               if PAGE.RunModal(696, Objects) = ACTION::LookupOK then
                                 Validate("Filter No.", Format(Objects."Object ID"));
                //-NPR5.46 [322752]
                           end;
                        "Line Type"::Customer:
                          begin
                            if PAGE.RunModal(22,Customer) = ACTION::LookupOK then
                              Validate("Filter No.", Customer."No.");
                          end;
                      end;
                end;

                // VENDOR
                if Type = Type::"Payment Form" then begin
                   case "Line Type" of
                     "Line Type"::Item :
                       begin
                         if PAGE.RunModal(PAGE::"Payment Type - Register", Betalingsvalg) = ACTION::LookupOK then begin
                           Validate("Filter No.", Betalingsvalg."No.");
                         end;
                       end;
                     "Line Type"::Internal :
                       begin
                         "TS Functions".Reset;
                         "TS Functions".SetFilter(Type, '%1|%2', "TS Functions".Type::Sale,
                                                  "TS Functions".Type::Generel);
                         if PAGE.RunModal(6014471, "TS Functions") = ACTION::LookupOK then
                           Validate("Filter No.", "TS Functions".Code);
                       end;
                    end;
                end;

                // FINANS
                if Type = Type::"G/L Account" then begin
                      Finans.Reset;
                      Finans.SetFilter("No.", '<>%1', '');
                      Finans.SetFilter(Blocked, '=%1', false);
                      Finans.SetFilter("Retail Payment", '=%1', true);
                      if PAGE.RunModal(PAGE::"G/L Account List", Finans) = ACTION::LookupOK then begin
                        Validate("Filter No.", Finans."No.");
                      end;
                end;

                if Type = Type::Comment then begin
                      "TS Functions".Reset;
                      "TS Functions".SetFilter(Type, '=%1', "TS Functions".Type::Comment);
                      if PAGE.RunModal(6014471, "TS Functions") = ACTION::LookupOK then begin
                        Validate("Filter No.", "TS Functions".Code);
                      end;
                end;

                if Type = Type::Discount then begin
                      "TS Functions".Reset;
                      "TS Functions".SetFilter(Type, '=%1', "TS Functions".Type::Discount);
                      if PAGE.RunModal(6014471, "TS Functions") = ACTION::LookupOK then begin
                        Validate("Filter No.", "TS Functions".Code);
                      end;
                end;

                if Type = Type::Prints then begin
                  case "Line Type" of
                    "Line Type"::Report:
                      begin
                        Objects.Reset;
                //-NPR5.46 [322752]
                //        Objects.SETFILTER(Type, '=%1', Objects.Type::Report);
                //        IF PAGE.RUNMODAL(358, Objects) = ACTION::LookupOK THEN
                //          VALIDATE("Filter No.", FORMAT(Objects.ID));

                         Objects.SetFilter("Object Type", '=%1', Objects."Object Type"::Report);
                         if PAGE.RunModal(696, Objects) = ACTION::LookupOK then
                          Validate("Filter No.", Format(Objects."Object ID"));
                //+NPR5.46 [322752]
                       end;
                    else begin
                      "TS Functions".Reset;
                      "TS Functions".SetFilter(Type, '=%1', "TS Functions".Type::Prints);
                      if PAGE.RunModal(6014471, "TS Functions") = ACTION::LookupOK then begin
                        Validate("Filter No.", "TS Functions".Code);
                      end;
                    end;
                  end;
                end;

                if Type = Type::Reports then begin
                      "TS Functions".Reset;
                      "TS Functions".SetFilter(Type, '=%1', "TS Functions".Type::Reports);
                      //IF PAGE.RUNMODAL(PAGE::"Touch Screen Functions", "TS Functions") = action::LookupOK THEN BEGIN
                      //  VALIDATE("Filter No.", "TS Functions".Code);
                      if PAGE.RunModal(282) = ACTION::LookupOK then;
                      //END;
                end;
            end;

            trigger OnValidate()
            var
                int1: Integer;
                MF_Translation: Record "Touch Screen - Meta F. Trans";
                Language: Record Language;
            begin
                if Type = Type::User then begin
                   Salesperson.SetRange(Code, "Filter No.");
                   if Salesperson.Find('-') then begin
                      Description := Salesperson.Name;
                      "Text Line 1" := Salesperson.Name;
                   end;
                end;

                if (Type = Type::Item) or (Type = Type::"Sale Form") then begin
                   case "Line Type" of
                      "Line Type"::Item : begin
                         Item.SetRange("No.", "Filter No.");
                         if Item.Find('-') then begin
                           Description := Item.Description;
                           "Text Line 1" := Item.Description;
                         end;
                      end;
                      "Line Type"::"Item Group" : begin
                         "Item Group".SetRange("No.", "Filter No.");
                         if "Item Group".Find('-') then begin
                            Description := "Item Group".Description;
                            "Text Line 1" := "Item Group".Description;
                         end;
                         if not Item.Get("Filter No.") then Message(text004,"Filter No.");
                      end;
                   end;
                end;

                if Type = Type::Insurance then begin
                           Forsikring.SetRange(Code, "Filter No.");
                           if Forsikring.Find('-') then begin
                              Description := Forsikring.Code;
                              "Text Line 1" := Forsikring.Code;
                           end;
                end;

                if Type in [Type::Login, Type::"Sale Functions", Type::"Payment Functions", Type::"Sale Form", Type::Comment,
                            Type::Discount, Type::Prints, Type::"Customer Functions", Type::"Item Functions"] then begin
                               case "Line Type" of
                                 "Line Type"::Internal :
                                   begin
                                     "TS Functions".SetRange(Code, "Filter No.");
                                     if "TS Functions".Find('-') then begin
                                       Language.Reset;
                                       Language.SetRange("Windows Language ID", GlobalLanguage);
                                       if Language.Find('-') then;
                                       if MF_Translation.Get("Filter No.", Language.Code) then begin
                                         Description   := MF_Translation.Description;
                                         "Text Line 1" := MF_Translation.Description;
                                       end else begin
                                         Description   := "TS Functions".Description;
                                         "Text Line 1" := "TS Functions"."Text Line 1";
                                       end;
                                     end;
                                   end;
                                 "Line Type"::Page :
                                   begin
                                     Evaluate(int1, "Filter No.");
                //-NPR5.46 [322752]
                //                     IF Objects.GET(Objects.Type::"2", '', int1) THEN BEGIN
                //                       Objects.CALCFIELDS(Caption);
                //                       Description   := Objects.Caption;
                //                       "Text Line 1" := Objects.Caption;
                                     //-NPR5.48 [334560]
                                     //IF Objects.GET(Objects."Object Type"::"2", int1) THEN BEGIN
                                     if Objects.Get(Objects."Object Type"::Page, int1) then begin
                                     //+NPR5.48 [334560]

                                       Objects.CalcFields("Object Name");
                                       Description   := Objects."Object Name";
                                       "Text Line 1" := Objects."Object Name";
                //+NPR5.46 [322752]
                                     end;
                                   end;
                                 "Line Type"::Report :
                                   begin
                                     Evaluate(int1, "Filter No.");
                //-NPR5.46 [322752]
                //                     IF Objects.GET(Objects.Type::Report, '', int1) THEN BEGIN
                //                       Objects.CALCFIELDS(Caption);
                //                       Description   := Objects.Caption;
                //                       "Text Line 1" := Objects.Caption;
                                     if Objects.Get(Objects."Object Type"::Report, int1) then begin
                                       Objects.CalcFields("Object Name");
                                       Description   := Objects."Object Name";
                                       "Text Line 1" := Objects."Object Name";
                //+NPR5.46 [322752]
                                    end;
                                   end;
                                 "Line Type"::Customer:
                                   begin
                                     Description     := Customer.Name;
                                     "Text Line 1"   := Customer.Name;
                                   end;
                                 "Line Type"::"Codeunit(sale)",
                                 "Line Type"::"Codeunit(line)" :
                                   begin
                                     Evaluate(int1, "Filter No.");
                //-NPR5.46 [322752]
                //                     IF Objects.GET(Objects.Type::Codeunit, '', int1) THEN BEGIN
                //                       Objects.CALCFIELDS(Caption);
                //                       Description   := Objects.Caption;
                //                       "Text Line 1" := Objects.Caption;
                                     if Objects.Get(Objects."Object Type"::Codeunit,int1) then begin
                                       Objects.CalcFields("Object Name");
                                       Description   := Objects."Object Name";
                                       "Text Line 1" := Objects."Object Name";
                //+NPR5.46 [322752]
                                     end;
                                   end;
                            end;
                end;

                if Type = Type::PaymentType then begin
                   Betalingsvalg.SetRange("No.", "Filter No.");
                   if Betalingsvalg.Find('-') then begin
                      Description := Betalingsvalg.Description;
                      "Text Line 1" := Betalingsvalg.Description;
                   end;
                end;

                if Type = Type::"Payment Form" then begin
                   Vendor.SetRange("No.", "Filter No.");
                   if Vendor.Find('-') then begin
                      Description := Vendor.Name;
                      "Text Line 1" := Vendor.Name;
                   end;
                end;

                if Type = Type::"G/L Account" then begin
                   Finans.SetRange("No.", "Filter No.");
                   if Finans.Find('-') then begin
                      Description := Finans.Name;
                      "Text Line 1" := Finans.Name;
                   end;
                end;
            end;
        }
        field(14;Visible;Boolean)
        {
            Caption = 'Visible';
            InitValue = true;
        }
        field(15;Password;Code[50])
        {
            Caption = 'Password';
            Description = 'User = password, Item = req. for selection';
        }
        field(16;Parent;Integer)
        {
            Caption = 'Parent';
            TableRelation = "Touch Screen - Menu Lines".Parent;
        }
        field(17;"Run as";Option)
        {
            Caption = 'Run as';
            Description = 'Use this button as lookup?';
            OptionCaption = ' ,Report,Form';
            OptionMembers = " ","Report",Form;

            trigger OnValidate()
            begin
                if "Run as" = 0 then begin
                   "Text Line 1" := DelChr("Text Line 1", '=', '...');
                end;

                if "Run as" = "Run as"::Report then begin
                   "Text Line 1" := "Text Line 1" + '...';
                end;
            end;
        }
        field(18;"Line Type";Option)
        {
            Caption = 'Line Type';
            Description = 'Vare,Varegruppe,Sortiment,M�rke,Kategori,Model,Variant';
            OptionCaption = 'Item,Item Group,Sortiment,Hyperlink,Report,Page,Internal,Codeunit(sale),Codeunit(line),Customer';
            OptionMembers = Item,"Item Group",Sortiment,Hyperlink,"Report","Page",Internal,"Codeunit(sale)","Codeunit(line)",Customer;
        }
        field(19;"Delete Rec";Boolean)
        {
            Caption = 'Delete Rec';
            Description = 'To be deleted';
        }
        field(20;Parametre;Text[250])
        {
            Caption = 'Parametre';
            Description = 'Parametre som kan blive overf�rt';
            TableRelation = IF (Type=CONST(Reports)) AllObj."Object Name";
            ValidateTableRelation = true;

            trigger OnLookup()
            var
                Int1: Integer;
            begin
                case Type of
                  Type::Prints :
                    begin
                      case "Line Type" of
                        "Line Type"::Report:
                           begin
                             Objects.Reset;
                //-NPR5.46 [322752]
                //             Objects.SETFILTER(Type, '=%1', Objects.Type::Table);
                //               IF PAGE.RUNMODAL(358, Objects) = ACTION::LookupOK THEN
                //                 VALIDATE(Parametre, FORMAT(Objects.ID));
                              Objects.SetFilter("Object Type", '=%1', Objects."Object Type"::Table);
                               if PAGE.RunModal(696, Objects) = ACTION::LookupOK then
                                 Validate(Parametre, Format(Objects."Object ID"));
                //+NPR5.46 [322752]
                           end;
                       end;
                   end;
                end;
            end;
        }
        field(21;"Journal Batch Name";Code[20])
        {
            Caption = 'Setting';
        }
        field(22;"Placement ID";Integer)
        {
            Caption = 'Placement ID';
        }
        field(23;"Placement X";Integer)
        {
            Caption = 'Placement X';
        }
        field(24;"Placement Y";Integer)
        {
            Caption = 'Placement Y';
        }
        field(25;Width;Integer)
        {
            Caption = 'Width';
        }
        field(26;Height;Integer)
        {
            Caption = 'Height';
        }
        field(27;"Menu No.";Code[20])
        {
            Caption = 'Menu No.';
            TableRelation = "Touch Screen - Layout".Code;
        }
        field(30;"Icon Resource";Code[30])
        {
            Caption = 'Icon Resource';
            TableRelation = "Product / Button  Images"."No." WHERE (Purpose=CONST("Touch Screen"));

            trigger OnValidate()
            begin
                if "Icon Resource" <> '' then
                  Clear("Button Image");
            end;
        }
        field(31;"Button Styling";Option)
        {
            Caption = 'Button Styling';
            OptionCaption = ''''',Green,Red,Dark Red,Grey,Purple,Indigo,Yellow,Orange,White';
            OptionMembers = "''",Green,Red,"Dark Red",Grey,Purple,Indigo,Yellow,Orange,White;
        }
        field(32;"Button Image";BLOB)
        {
            Caption = 'Button Image';
            SubType = Bitmap;
        }
        field(33;"Button Brush";Text[30])
        {
            Caption = 'Button Brush';
        }
        field(35;HasChildren;Integer)
        {
            Caption = 'HasChildren';
        }
        field(40;"Grid Position";Option)
        {
            Caption = 'Grid Position';
            OptionCaption = 'Bottom Center,Right';
            OptionMembers = "Bottom Center",Right;
        }
        field(50;"Icon Class";Text[50])
        {
            Caption = 'Icon Class';
            Description = 'CASE 213003';
        }
        field(51;"Show Behavior";Option)
        {
            Caption = 'Show Behavior';
            Description = 'CASE 222539';
            OptionCaption = 'Always,Desktop,App';
            OptionMembers = Always,Desktop,App;
        }
    }

    keys
    {
        key(Key1;"Menu No.",Type,"No.")
        {
        }
        key(Key2;"Filter No.")
        {
        }
        key(Key3;Terminal,"Only Visible To")
        {
        }
        key(Key4;"Run as")
        {
        }
        key(Key5;Type,"No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Salesperson: Record "Salesperson/Purchaser";
        Item: Record Item;
        "Item Group": Record "Item Group";
        Sortiment: Record "Discount Priority";
        "TS Functions": Record "Touch Screen - Meta Functions";
        text001: Label 'Reconstructing list.\This only takes a minute.\Continue?';
        text002: Label 'Reconstruction finished!';
        Betalingsvalg: Record "Payment Type POS";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Finans: Record "G/L Account";
        oldrec: Record "Touch Screen - Menu Lines";
        newrec: Record "Touch Screen - Menu Lines";
        i: BigInteger;
        currlinie: Record "Touch Screen - Menu Lines";
        denneLinie: Record "Touch Screen - Menu Lines";
        "movetoNo.": BigInteger;
        text003: Label 'Error: You have to setup "Customer posting group" on customer %1.';
        atlevel: Integer;
        text004: Label 'NOTE! Remember to create item group %1 as item, if you want item group direct sale!';
        text005: Label 'NOTE! Remember to create selection %1 as item, if you want selection direct sale!';
        A: Action;
        Forsikring: Record "Insurance Companies";
        Objects: Record AllObj;

    procedure Restrukturer(Linie: Record "Touch Screen - Menu Lines";Ask: Boolean)
    var
        i: Integer;
        currlinie: Record "Touch Screen - Menu Lines";
        t001: Label 'Line.Type not found!';
    begin
        // Restrukturer

        if Ask then
           if not Confirm(text001) then exit;

        Reset;
        SetRange(Type, Linie.Type);
        if not Find('-') then exit;

        repeat
          currlinie.Copy(Rec);
          currlinie.Type := Type::Temp;
          currlinie.Insert;
        until Next = 0;

        Reset;
        SetRange(Type, Linie.Type);
        DeleteAll;

        Reset;
        SetRange(Type, Type::Temp);
        if Find('-') then;

        i := 10000;
        repeat
          CalcFields("Button Image");
          currlinie.Copy(Rec);
          currlinie.Type := Linie.Type;
          currlinie."No." := i;
          currlinie.Insert;
          i := i + 10000;
        until Next = 0;

        Reset;
        SetRange(Type, Type::Temp);
        DeleteAll;
        SetRange(Type, Linie.Type);

        if Get('',Linie.Type,Linie."No.") then;

        if Ask then Message(text002);
    end;

    procedure moveGroup(var Linie: Record "Touch Screen - Menu Lines";Direction: Integer)
    var
        t001: Label 'The Group is too big to move';
    begin

        Reset;
        SetRange(Type, Linie.Type);
        Find('-');

        if Direction > 0 then begin
           denneLinie.Reset;
           denneLinie.Copy(Linie);
           denneLinie.SetRange("No.", findNextNoAtSameLevel(Linie,1));
           denneLinie.Find('-');
           "movetoNo." := findNextNoAtSameLevel(denneLinie,2) - 10000
        end else
           "movetoNo." := findPrevNoAtSameLevel(Linie) - 10000;

        // move group to type::temp temporarily
        i := 1;
        Rec := Linie;
        currlinie.Reset;
        currlinie.Copy(Rec);
        currlinie.Type := Type::Temp;
        currlinie."No." := "movetoNo." + i;
        currlinie.Insert;
        Mark(true);
        i += 1;

        repeat
          if i = 10000 then Error(t001);

          if Level > Linie.Level then begin
             currlinie.Copy(Rec);
             currlinie.Type := Type::Temp;
             currlinie."No." := "movetoNo." + i;
             currlinie.Insert;
             Mark(true);
             i += 1;
          end;
        until (Next = 0) or (Level <= Linie.Level);

        oldrec.Reset;
        oldrec.SetRange(Type, Type::Temp);
        oldrec.Find('-');
        i := oldrec.Count;

        repeat
          currlinie.Copy(oldrec);
          currlinie.Type := Linie.Type;
          currlinie.Insert;
        until oldrec.Next = 0;

        oldrec.DeleteAll;
        oldrec.Reset;

        MarkedOnly(true);
        Find('-');
        repeat
          Delete;
        until Next = 0;
        MarkedOnly(false);

        Restrukturer(Linie,false);
    end;

    procedure findNextNoAtSameLevel(Linie: Record "Touch Screen - Menu Lines";checkno: Integer): BigInteger
    begin
        // find next no. at same level

        newrec.Reset;
        newrec := Linie;

        i := 1;

        repeat
          if newrec.Next = 0 then begin
             if (checkno = 1) and (i = 1) then Error('');
        //     IF (checkno = 2) AND (i = 1) THEN EXIT(newrec."No." + 20000);
          end;
          i += 1;
        until (newrec.Level <= Linie.Level);

        exit(newrec."No.");
    end;

    procedure findPrevNoAtSameLevel(Linie: Record "Touch Screen - Menu Lines"): BigInteger
    begin
        // findPrevNoAtSameLevel

        newrec.Reset;
        newrec := Linie;

        repeat
          if newrec.Next(-1) = 0 then exit(newrec."No.");
        until (newrec.Level <= Linie.Level);

        exit(newrec."No.");
    end;

    procedure levelGroup(Linie: Record "Touch Screen - Menu Lines";Direction: Integer): Boolean
    var
        cl: Integer;
    begin

        Reset;
        Rec := Linie;

        if (Direction < 0) and (Level = 0) then exit(false);
        if (Direction > 0) and (Level = 10) then exit(false);


        Level += Direction;
        Modify;
        Next;

        repeat
          cl := Level;
          if cl > Linie.Level then begin
             Level += Direction;
             Modify;
          end;
        until (Next = 0) or (cl <= Linie.Level);
    end;

    procedure setOnlyVisibleTo(rec1: Record "Touch Screen - Menu Lines";set2user: Code[20])
    var
        thislevel: Integer;
        thisNo: BigInteger;
    begin

        thislevel := rec1.Level;
        thisNo := rec1."No.";

        repeat
          rec1."Only Visible To" := set2user;
          rec1.Modify;
          if rec1.Next = 0 then thislevel := 11;
        until (rec1.Level <= thislevel);
    end;

    procedure setTerminal(rec1: Record "Touch Screen - Menu Lines";set2user: Code[20])
    var
        thislevel: Integer;
        thisNo: BigInteger;
    begin
        thislevel := rec1.Level;
        thisNo := rec1."No.";

        repeat
          rec1.Terminal := set2user;
          rec1.Modify;
          if rec1.Next = 0 then thislevel := 11;
        until (rec1.Level <= thislevel);
    end;

    procedure importItemsFromGroup(gruppesalgJN: Boolean)
    var
        vare: Record Item;
        i: Integer;
        vg: Code[20];
        cl: Integer;
        sortiment1: Record "Discount Priority";
    begin
        //importItemsFromGroup(gruppesalgJN : Boolean;FromGroup : Code[20])
        
        i := "No.";
        vg := "Filter No.";
        cl := Level;
        
        case "Line Type" of
          "Line Type"::"Item Group" :
            begin
              vare.SetCurrentKey("Group sale","Item Group","Vendor No.");
              vare.SetRange("Item Group", vg);
              vare.Find('-');
              repeat
                i += 1;
                Init;
                Type := Type::Item;
                "Line Type" := "Line Type"::Item;
                "No." := i;
                Level := cl+1;
                "Filter No." := vare."No.";
                Description := vare.Description;
                "Text Line 1" := Description;
                "Text Line 2" := vare."Description 2";
                Insert(true);
              until vare.Next = 0;
            end;
          "Line Type"::Sortiment :
            begin
              Error('NOT IMPLEMENTED');
              /*
              vare.SETCURRENTKEY(Assortment);
              vare.SETRANGE("Group sale", FALSE);
              vare.SETRANGE(Assortment, vg);
              vare.FIND('-');
              REPEAT
                i += 1;
                INIT;
                Type := Type::Item;
                "Line Type" := "Line Type"::Item;
                "No." := i;
                Level := cl+1;
                "Filter No." := vare."No.";
                Description := vare.Description;
                "Text Line 1" := Description;
                "Text Line 2" := vare."Description 2";
                INSERT(TRUE);
              UNTIL vare.NEXT = 0;
              */
            end;
        end;

    end;

    procedure importIGstructure(Linie: Record "Touch Screen - Menu Lines")
    var
        varegruppe1: Record "Item Group";
        varegruppe2: Record "Item Group";
        i: Integer;
        vg: Code[20];
        cl: Integer;
    begin
        //importIGstructure
        
        varegruppe1.Reset;
        varegruppe1.SetCurrentKey("Parent Item Group No.");
        varegruppe1.SetRange("Parent Item Group No.", "Filter No.");
        
        i := "No.";
        vg := "Filter No.";
        cl := Level;
        
        if varegruppe1.Find('-') then repeat
                i += 1;
                Init;
                Type := Type::Item;
                "Line Type" := "Line Type"::"Item Group";
                "No." := i;
                Level := cl + 1;
                "Filter No." := varegruppe1."No.";
                //-NPR5.48 [331261]
                /*
                Description := COPYSTR(varegruppe1.Description,1,50);
                "Text Line 1" := COPYSTR(varegruppe1.Description,1,30);
                "Text Line 2" := COPYSTR(varegruppe1.Description,31,30);
                */
                Description := CopyStr(varegruppe1.Description,1,MaxStrLen(Description));
                "Text Line 1" := CopyStr(varegruppe1.Description,1,MaxStrLen("Text Line 1"));
                "Text Line 2" := CopyStr(varegruppe1.Description,MaxStrLen("Text Line 1") + 1,MaxStrLen("Text Line 2"));
                //-NPR5.48 [331261]
                Insert(true);
        until varegruppe1.Next = 0;
        
        
        Restrukturer(Linie, false);

    end;

    procedure moveMarked(Linie: Record "Touch Screen - Menu Lines";Direction: Integer)
    var
        t001: Label 'The Group is too big to move';
    begin


        Reset;
        SetRange(Type, Linie.Type);
        if Find('-') then;

        if Direction > 0 then begin
           denneLinie.Reset;
           denneLinie.Copy(Linie);
           denneLinie.SetRange("No.", findNextNoAtSameLevel(Linie,1));
           denneLinie.Find('-');
           "movetoNo." := findNextNoAtSameLevel(denneLinie,2) - 10000
        end else
           "movetoNo." := findPrevNoAtSameLevel(Linie) - 10000;

        // move group to type::temp temporarily
        i := 1;
        Rec := Linie;
        currlinie.Reset;
        currlinie.Copy(Rec);
        currlinie.Type := Type::Temp;
        currlinie."No." := "movetoNo." + i;
        currlinie.Insert;
        Mark(true);
        i += 1;

        repeat
          if i = 10000 then Error(t001);
          MarkedOnly(true);

          currlinie.Copy(Rec);
          currlinie.Type := Type::Temp;
          currlinie."No." := "movetoNo." + i;
          currlinie.Insert;
          i += 1;
        until (Next = 0);

        oldrec.Reset;
        oldrec.SetRange(Type, Type::Temp);
        oldrec.Find('-');
        i := oldrec.Count;

        repeat
          currlinie.Copy(oldrec);
          currlinie.Type := Linie.Type;
        //  IF NOT CONFIRM(currlinie.Description) THEN ERROR('');
          currlinie.Insert;
        until oldrec.Next = 0;

        oldrec.DeleteAll;
        oldrec.Reset;

        MarkedOnly(true);
        Find('-');
        repeat
          Delete;
        until Next = 0;
        MarkedOnly(false);

        Restrukturer(Linie,false);
    end;

    procedure levelGroupMarked_Old(Direction: Integer): Boolean
    var
        cl: Integer;
    begin

        Reset;
        MarkedOnly(true);
        if not Find('-') then exit(false);

        if (Direction < 0) and (Level = 0) then exit(false);
        if (Direction > 0) and (Level = 10) then exit(false);

        repeat
          cl := Level;
          Level += Direction;
          Modify;
        until (Next = 0);

        MarkedOnly(false);
        Error('sdf');
    end;
}


table 6060018 "NPR VAT EV Entry"
{
    Access = Internal;
    Caption = 'VAT EV Entry';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(7; "VAT Reporting Date"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;
        }
        field(10; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(50; "Field 1_1"; Decimal)
        {
            Caption = 'Field 1.1';
            DataClassification = CustomerContent;
        }
        field(51; "Field 1_2"; Decimal)
        {
            Caption = 'Field 1.2';
            DataClassification = CustomerContent;
        }
        field(52; "Field 1_3"; Decimal)
        {
            Caption = 'Field 1.3';
            DataClassification = CustomerContent;
        }
        field(53; "Field 1_4"; Decimal)
        {
            Caption = 'Field 1.4';
            DataClassification = CustomerContent;
        }
        field(54; "Field 1_5"; Decimal)
        {
            Caption = 'Field 1.5';
            DataClassification = CustomerContent;
        }
        field(56; "Field 1_6"; Decimal)
        {
            Caption = 'Field 1.6';
            DataClassification = CustomerContent;
        }
        field(57; "Field 1_7"; Decimal)
        {
            Caption = 'Field 1.7';
            DataClassification = CustomerContent;
        }
        field(70; "Field 2_1"; Decimal)
        {
            Caption = 'Field 2.1';
            DataClassification = CustomerContent;
        }
        field(71; "Field 2_2"; Decimal)
        {
            Caption = 'Field 2.2';
            DataClassification = CustomerContent;
        }
        field(72; "Field 2_3"; Decimal)
        {
            Caption = 'Field 2.3';
            DataClassification = CustomerContent;
        }
        field(73; "Field 2_4"; Decimal)
        {
            Caption = 'Field 2.4';
            DataClassification = CustomerContent;
        }
        field(74; "Field 2_5"; Decimal)
        {
            Caption = 'Field 2.5';
            DataClassification = CustomerContent;
        }
        field(75; "Field 2_6"; Decimal)
        {
            Caption = 'Field 2.6';
            DataClassification = CustomerContent;
        }
        field(76; "Field 2_7"; Decimal)
        {
            Caption = 'Field 2.7';
            DataClassification = CustomerContent;
        }
        field(90; "Field 3_1_1"; Decimal)
        {
            Caption = 'Field 3.1 Base';
            DataClassification = CustomerContent;
        }
        field(91; "Field 3_1_2"; Decimal)
        {
            Caption = 'Field 3.1 Amount';
            DataClassification = CustomerContent;
        }
        field(92; "Field 3_1_3"; Decimal)
        {
            Caption = 'Field 3.1 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(93; "Field 3_1_4"; Decimal)
        {
            Caption = 'Field 3.1 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(95; "Field 3_2_1"; Decimal)
        {
            Caption = 'Field 3.2 Base';
            DataClassification = CustomerContent;
        }
        field(96; "Field 3_2_2"; Decimal)
        {
            Caption = 'Field 3.2 Amount';
            DataClassification = CustomerContent;
        }
        field(97; "Field 3_2_3"; Decimal)
        {
            Caption = 'Field 3.2 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(98; "Field 3_2_4"; Decimal)
        {
            Caption = 'Field 3.2 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(100; "Field 3_3_1"; Decimal)
        {
            Caption = 'Field 3.3 Base';
            DataClassification = CustomerContent;
        }
        field(101; "Field 3_3_2"; Decimal)
        {
            Caption = 'Field 3.3 Amount';
            DataClassification = CustomerContent;
        }
        field(102; "Field 3_3_3"; Decimal)
        {
            Caption = 'Field 3.3 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(103; "Field 3_3_4"; Decimal)
        {
            Caption = 'Field 3.3 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(105; "Field 3_4_1"; Decimal)
        {
            Caption = 'Field 3.4 Base';
            DataClassification = CustomerContent;
        }
        field(106; "Field 3_4_2"; Decimal)
        {
            Caption = 'Field 3.4 Amount';
            DataClassification = CustomerContent;
        }
        field(107; "Field 3_4_3"; Decimal)
        {
            Caption = 'Field 3.4 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(108; "Field 3_4_4"; Decimal)
        {
            Caption = 'Field 3.4 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(110; "Field 3_5_1"; Decimal)
        {
            Caption = 'Field 3.5 Base';
            DataClassification = CustomerContent;
        }
        field(111; "Field 3_5_2"; Decimal)
        {
            Caption = 'Field 3.5 Amount';
            DataClassification = CustomerContent;
        }
        field(112; "Field 3_5_3"; Decimal)
        {
            Caption = 'Field 3.5 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(113; "Field 3_5_4"; Decimal)
        {
            Caption = 'Field 3.5 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(115; "Field 3_6_1"; Decimal)
        {
            Caption = 'Field 3.6 Base';
            DataClassification = CustomerContent;
        }
        field(116; "Field 3_6_2"; Decimal)
        {
            Caption = 'Field 3.6 Amount';
            DataClassification = CustomerContent;
        }
        field(117; "Field 3_6_3"; Decimal)
        {
            Caption = 'Field 3.6 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(118; "Field 3_6_4"; Decimal)
        {
            Caption = 'Field 3.6 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(120; "Field 3_7_1"; Decimal)
        {
            Caption = 'Field 3.7 Base';
            DataClassification = CustomerContent;
        }
        field(121; "Field 3_7_2"; Decimal)
        {
            Caption = 'Field 3.7 Amount';
            DataClassification = CustomerContent;
        }
        field(122; "Field 3_7_3"; Decimal)
        {
            Caption = 'Field 3.7 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(123; "Field 3_7_4"; Decimal)
        {
            Caption = 'Field 3.7 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(125; "Field 3_8_1"; Decimal)
        {
            Caption = 'Field 3.8 Base';
            DataClassification = CustomerContent;
        }
        field(126; "Field 3_8_2"; Decimal)
        {
            Caption = 'Field 3.8 Amount';
            DataClassification = CustomerContent;
        }
        field(127; "Field 3_8_3"; Decimal)
        {
            Caption = 'Field 3.8 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(128; "Field 3_8_4"; Decimal)
        {
            Caption = 'Field 3.8 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(130; "Field 3_9_1"; Decimal)
        {
            Caption = 'Field 3.9 Base';
            DataClassification = CustomerContent;
        }
        field(131; "Field 3_9_2"; Decimal)
        {
            Caption = 'Field 3.9 Amount';
            DataClassification = CustomerContent;
        }
        field(132; "Field 3_9_3"; Decimal)
        {
            Caption = 'Field 3.9 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(134; "Field 3_9_4"; Decimal)
        {
            Caption = 'Field 3.9 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(137; "Field 3_10_2"; Decimal)
        {
            Caption = 'Field 3.9 Amount';
            DataClassification = CustomerContent;
        }
        field(139; "Field 3_10_4"; Decimal)
        {
            Caption = 'Field 3.9 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(150; "Field 3a_1_1"; Decimal)
        {
            Caption = 'Field 3a.1 Amount';
            DataClassification = CustomerContent;
        }
        field(151; "Field 3a_1_2"; Decimal)
        {
            Caption = 'Field 3a.1 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(152; "Field 3a_2_1"; Decimal)
        {
            Caption = 'Field 3a.2 Amount';
            DataClassification = CustomerContent;
        }
        field(153; "Field 3a_2_2"; Decimal)
        {
            Caption = 'Field 3a.2 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(154; "Field 3a_3_1"; Decimal)
        {
            Caption = 'Field 3a.3 Amount';
            DataClassification = CustomerContent;
        }
        field(155; "Field 3a_3_2"; Decimal)
        {
            Caption = 'Field 3a.3 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(156; "Field 3a_4_1"; Decimal)
        {
            Caption = 'Field 3a.4 Amount';
            DataClassification = CustomerContent;
        }
        field(157; "Field 3a_4_2"; Decimal)
        {
            Caption = 'Field 3a.4 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(158; "Field 3a_5_1"; Decimal)
        {
            Caption = 'Field 3a.5 Amount';
            DataClassification = CustomerContent;
        }
        field(159; "Field 3a_5_2"; Decimal)
        {
            Caption = 'Field 3a.5 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(160; "Field 3a_6_1"; Decimal)
        {
            Caption = 'Field 3a.6 Amount';
            DataClassification = CustomerContent;
        }
        field(161; "Field 3a_6_2"; Decimal)
        {
            Caption = 'Field 3a.6 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(162; "Field 3a_7_1"; Decimal)
        {
            Caption = 'Field 3a.7 Amount';
            DataClassification = CustomerContent;
        }
        field(163; "Field 3a_7_2"; Decimal)
        {
            Caption = 'Field 3a.7 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(164; "Field 3a_8_1"; Decimal)
        {
            Caption = 'Field 3a.8 Base';
            DataClassification = CustomerContent;
        }
        field(165; "Field 3a_8_2"; Decimal)
        {
            Caption = 'Field 3a.8 Amount';
            DataClassification = CustomerContent;
        }
        field(166; "Field 3a_9_1"; Decimal)
        {
            Caption = 'Field 3a.9 Base';
            DataClassification = CustomerContent;
        }
        field(167; "Field 3a_9_2"; Decimal)
        {
            Caption = 'Field 3a.9 Amount';
            DataClassification = CustomerContent;
        }
        field(170; "Field 4_1_1"; Decimal)
        {
            Caption = 'Field 4.1.1 Base';
            DataClassification = CustomerContent;
        }
        field(171; "Field 4_1_2"; Decimal)
        {
            Caption = 'Field 4.1.2 Base';
            DataClassification = CustomerContent;
        }
        field(172; "Field 4_1_3"; Decimal)
        {
            Caption = 'Field 4.1.3 Base';
            DataClassification = CustomerContent;
        }
        field(173; "Field 4_1_4"; Decimal)
        {
            Caption = 'Field 4.1.4 Amount';
            DataClassification = CustomerContent;
        }
        field(174; "Field 4_2_1_1"; Decimal)
        {
            Caption = 'Field 4.2.1.1 Base';
            DataClassification = CustomerContent;
        }
        field(175; "Field 4_2_1_2"; Decimal)
        {
            Caption = 'Field 4.2.1.2 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(176; "Field 4_2_2_1"; Decimal)
        {
            Caption = 'Field 4.2.2.1 Base';
            DataClassification = CustomerContent;
        }
        field(177; "Field 4_2_2_2"; Decimal)
        {
            Caption = 'Field 4.2.2.2 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(178; "Field 4_2_3_1"; Decimal)
        {
            Caption = 'Field 4.2.3.1 Base';
            DataClassification = CustomerContent;
        }
        field(179; "Field 4_2_3_2"; Decimal)
        {
            Caption = 'Field 4.2.3.2 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(180; "Field 4_2_4_3"; Decimal)
        {
            Caption = 'Field 4.2.4.3 Amount';
            DataClassification = CustomerContent;
        }
        field(181; "Field 4_2_4_4"; Decimal)
        {
            Caption = 'Field 4.2.4.4 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(190; "Field 5_1"; Decimal)
        {
            Caption = 'Field 5.1';
            DataClassification = CustomerContent;
        }
        field(191; "Field 5_2"; Decimal)
        {
            Caption = 'Field 5.2';
            DataClassification = CustomerContent;
        }
        field(192; "Field 5_3"; Decimal)
        {
            Caption = 'Field 5.3';
            DataClassification = CustomerContent;
        }
        field(193; "Field 5_4"; Decimal)
        {
            Caption = 'Field 5.4';
            DataClassification = CustomerContent;
        }
        field(194; "Field 5_5"; Decimal)
        {
            Caption = 'Field 5.5';
            DataClassification = CustomerContent;
        }
        field(196; "Field 5_6"; Decimal)
        {
            Caption = 'Field 5.6';
            DataClassification = CustomerContent;
        }
        field(197; "Field 5_7"; Decimal)
        {
            Caption = 'Field 5.7';
            DataClassification = CustomerContent;
        }
        field(200; "Field 6_1"; Decimal)
        {
            Caption = 'Field 6.1';
            DataClassification = CustomerContent;
        }
        field(201; "Field 6_2_1_1"; Decimal)
        {
            Caption = 'Field 6.2.1';
            DataClassification = CustomerContent;
        }
        field(202; "Field 6_2_1_2"; Decimal)
        {
            Caption = 'Field 6.2.1 (Special)';
            DataClassification = CustomerContent;
        }
        field(203; "Field 6_2_2_1"; Decimal)
        {
            Caption = 'Field 6.2.2';
            DataClassification = CustomerContent;
        }
        field(204; "Field 6_2_2_2"; Decimal)
        {
            Caption = 'Field 6.2.2 (Special)';
            DataClassification = CustomerContent;
        }
        field(205; "Field 6_2_3_1"; Decimal)
        {
            Caption = 'Field 6.2.3';
            DataClassification = CustomerContent;
        }
        field(206; "Field 6_2_3_2"; Decimal)
        {
            Caption = 'Field 6.2.3 (Special)';
            DataClassification = CustomerContent;
        }
        field(207; "Field 6_3"; Decimal)
        {
            Caption = 'Field 6.3';
            DataClassification = CustomerContent;
        }
        field(208; "Field 6_4"; Decimal)
        {
            Caption = 'Field 6.4';
            DataClassification = CustomerContent;
        }
        field(210; "Field 7_1_1"; Decimal)
        {
            Caption = 'Field 7.1';
            DataClassification = CustomerContent;
        }
        field(211; "Field 7_2_1"; Decimal)
        {
            Caption = 'Field 7.2';
            DataClassification = CustomerContent;
        }
        field(212; "Field 7_3_2"; Decimal)
        {
            Caption = 'Field 7.3';
            DataClassification = CustomerContent;
        }
        field(213; "Field 7_4_2"; Decimal)
        {
            Caption = 'Field 7.4';
            DataClassification = CustomerContent;
        }
        field(215; "Field 8a_1_1"; Decimal)
        {
            Caption = 'Field 8a.1 Base';
            DataClassification = CustomerContent;
        }
        field(216; "Field 8a_1_2"; Decimal)
        {
            Caption = 'Field 8a.1 Amount';
            DataClassification = CustomerContent;
        }
        field(217; "Field 8a_1_3"; Decimal)
        {
            Caption = 'Field 8a.1 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(218; "Field 8a_1_4"; Decimal)
        {
            Caption = 'Field 8a.1 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(219; "Field 8a_2_1"; Decimal)
        {
            Caption = 'Field 8a.2 Base';
            DataClassification = CustomerContent;
        }
        field(220; "Field 8a_2_2"; Decimal)
        {
            Caption = 'Field 8a.2 Amount';
            DataClassification = CustomerContent;
        }
        field(221; "Field 8a_2_3"; Decimal)
        {
            Caption = 'Field 8a.2 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(222; "Field 8a_2_4"; Decimal)
        {
            Caption = 'Field 8a.2 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(223; "Field 8a_3_1"; Decimal)
        {
            Caption = 'Field 8a.3 Base';
            DataClassification = CustomerContent;
        }
        field(224; "Field 8a_3_2"; Decimal)
        {
            Caption = 'Field 8a.3 Amount';
            DataClassification = CustomerContent;
        }
        field(225; "Field 8a_3_3"; Decimal)
        {
            Caption = 'Field 8a.3 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(226; "Field 8a_3_4"; Decimal)
        {
            Caption = 'Field 8a.3 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(227; "Field 8a_4_1"; Decimal)
        {
            Caption = 'Field 8a.4 Base';
            DataClassification = CustomerContent;
        }
        field(228; "Field 8a_4_2"; Decimal)
        {
            Caption = 'Field 8a.4 Amount';
            DataClassification = CustomerContent;
        }
        field(229; "Field 8a_4_3"; Decimal)
        {
            Caption = 'Field 8a.4 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(230; "Field 8a_4_4"; Decimal)
        {
            Caption = 'Field 8a.4 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(231; "Field 8a_5_1"; Decimal)
        {
            Caption = 'Field 8a.5 Base';
            DataClassification = CustomerContent;
        }
        field(232; "Field 8a_5_2"; Decimal)
        {
            Caption = 'Field 8a.5 Amount';
            DataClassification = CustomerContent;
        }
        field(233; "Field 8a_5_3"; Decimal)
        {
            Caption = 'Field 8a.5 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(234; "Field 8a_5_4"; Decimal)
        {
            Caption = 'Field 8a.5 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(235; "Field 8a_6_1"; Decimal)
        {
            Caption = 'Field 8a.6 Base';
            DataClassification = CustomerContent;
        }
        field(236; "Field 8a_6_3"; Decimal)
        {
            Caption = 'Field 8a.6 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(237; "Field 8a_7_1"; Decimal)
        {
            Caption = 'Field 8a.7 Base';
            DataClassification = CustomerContent;
        }
        field(238; "Field 8a_7_2"; Decimal)
        {
            Caption = 'Field 8a.7 Amount';
            DataClassification = CustomerContent;
        }
        field(239; "Field 8a_7_3"; Decimal)
        {
            Caption = 'Field 8a.7 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(240; "Field 8a_7_4"; Decimal)
        {
            Caption = 'Field 8a.7 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(241; "Field 8a_8_2"; Decimal)
        {
            Caption = 'Field 8a.8 Amount';
            DataClassification = CustomerContent;
        }
        field(242; "Field 8a_8_4"; Decimal)
        {
            Caption = 'Field 8a.8 Amount (Special)';
            DataClassification = CustomerContent;
        }
        field(243; "Field 8b_1_1"; Decimal)
        {
            Caption = 'Field 8b.1 Base';
            DataClassification = CustomerContent;
        }
        field(244; "Field 8b_1_2"; Decimal)
        {
            Caption = 'Field 8b.1 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(245; "Field 8b_2_1"; Decimal)
        {
            Caption = 'Field 8b.2 Base';
            DataClassification = CustomerContent;
        }
        field(246; "Field 8b_2_2"; Decimal)
        {
            Caption = 'Field 8b.2 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(247; "Field 8b_3_1"; Decimal)
        {
            Caption = 'Field 8b.3 Base';
            DataClassification = CustomerContent;
        }
        field(248; "Field 8b_3_2"; Decimal)
        {
            Caption = 'Field 8b.3 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(249; "Field 8b_4_1"; Decimal)
        {
            Caption = 'Field 8b.4 Base';
            DataClassification = CustomerContent;
        }
        field(250; "Field 8b_4_2"; Decimal)
        {
            Caption = 'Field 8b.4 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(251; "Field 8b_5_1"; Decimal)
        {
            Caption = 'Field 8b.5 Base';
            DataClassification = CustomerContent;
        }
        field(252; "Field 8b_5_2"; Decimal)
        {
            Caption = 'Field 8b.5 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(253; "Field 8b_6_1"; Decimal)
        {
            Caption = 'Field 8b.6 Base';
            DataClassification = CustomerContent;
        }
        field(254; "Field 8b_6_2"; Decimal)
        {
            Caption = 'Field 8b.6 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(255; "Field 8b_7_1"; Decimal)
        {
            Caption = 'Field 8b.7 Base';
            DataClassification = CustomerContent;
        }
        field(256; "Field 8b_7_2"; Decimal)
        {
            Caption = 'Field 8b.7 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(257; "Field 8v_1"; Decimal)
        {
            Caption = 'Field 8v.1';
            DataClassification = CustomerContent;
        }
        field(258; "Field 8v_2"; Decimal)
        {
            Caption = 'Field 8v.2';
            DataClassification = CustomerContent;
        }
        field(259; "Field 8v_3"; Decimal)
        {
            Caption = 'Field 8v.3';
            DataClassification = CustomerContent;
        }
        field(260; "Field 8v_4"; Decimal)
        {
            Caption = 'Field 8v.4';
            DataClassification = CustomerContent;
        }
        field(261; "Field 8g_1_1"; Decimal)
        {
            Caption = 'Field 8g.1 Base';
            DataClassification = CustomerContent;
        }
        field(262; "Field 8g_1_2"; Decimal)
        {
            Caption = 'Field 8g.1 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(263; "Field 8g_2_1"; Decimal)
        {
            Caption = 'Field 8g.2 Base';
            DataClassification = CustomerContent;
        }
        field(264; "Field 8g_2_2"; Decimal)
        {
            Caption = 'Field 8g.2 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(265; "Field 8g_3_1"; Decimal)
        {
            Caption = 'Field 8g.3 Base';
            DataClassification = CustomerContent;
        }
        field(266; "Field 8g_3_2"; Decimal)
        {
            Caption = 'Field 8g.3 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(267; "Field 8g_4_1"; Decimal)
        {
            Caption = 'Field 8g.4 Base';
            DataClassification = CustomerContent;
        }
        field(268; "Field 8g_4_2"; Decimal)
        {
            Caption = 'Field 8g.4 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(269; "Field 8g_5_1"; Decimal)
        {
            Caption = 'Field 8g.5 Base';
            DataClassification = CustomerContent;
        }
        field(270; "Field 8g_5_2"; Decimal)
        {
            Caption = 'Field 8g.5 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(271; "Field 8g_6_1"; Decimal)
        {
            Caption = 'Field 8g.6 Base';
            DataClassification = CustomerContent;
        }
        field(272; "Field 8g_6_2"; Decimal)
        {
            Caption = 'Field 8g.6 Base (Special)';
            DataClassification = CustomerContent;
        }
        field(273; "Field 8d_1"; Decimal)
        {
            Caption = 'Field 8d.1';
            DataClassification = CustomerContent;
        }
        field(274; "Field 8d_2"; Decimal)
        {
            Caption = 'Field 8d.2';
            DataClassification = CustomerContent;
        }
        field(275; "Field 8d_3"; Decimal)
        {
            Caption = 'Field 8d.3';
            DataClassification = CustomerContent;
        }
        field(276; "Field 8dj"; Decimal)
        {
            Caption = 'Field 8dj';
            DataClassification = CustomerContent;
        }
        field(277; "Field 8e_1"; Decimal)
        {
            Caption = 'Field 8e.1';
            DataClassification = CustomerContent;
        }
        field(278; "Field 8e_2"; Decimal)
        {
            Caption = 'Field 8e.2';
            DataClassification = CustomerContent;
        }
        field(279; "Field 8e_3"; Decimal)
        {
            Caption = 'Field 8e.3';
            DataClassification = CustomerContent;
        }
        field(280; "Field 8e_4"; Decimal)
        {
            Caption = 'Field 8e.4';
            DataClassification = CustomerContent;
        }
        field(281; "Field 8e_5"; Decimal)
        {
            Caption = 'Field 8e.5';
            DataClassification = CustomerContent;
        }
        field(282; "Field 8e_6"; Decimal)
        {
            Caption = 'Field 8e.6';
            DataClassification = CustomerContent;
        }
        field(283; "Field 9"; Decimal)
        {
            Caption = 'Field 9';
            DataClassification = CustomerContent;
        }
        field(284; "Field 9a_1"; Decimal)
        {
            Caption = 'Field 9a.1';
            DataClassification = CustomerContent;
        }
        field(285; "Field 9a_2"; Decimal)
        {
            Caption = 'Field 9a.2';
            DataClassification = CustomerContent;
        }
        field(286; "Field 9a_3"; Decimal)
        {
            Caption = 'Field 9a.3';
            DataClassification = CustomerContent;
        }
        field(287; "Field 9a_4"; Decimal)
        {
            Caption = 'Field 9a.4';
            DataClassification = CustomerContent;
        }
        field(288; "Field 10"; Decimal)
        {
            Caption = 'Field 10';
            DataClassification = CustomerContent;
        }
        field(289; "Field 11_1"; Decimal)
        {
            Caption = 'Field 11.1';
            DataClassification = CustomerContent;
        }
        field(290; "Field 11_2"; Decimal)
        {
            Caption = 'Field 11.2';
            DataClassification = CustomerContent;
        }
        field(291; "Field 11_3"; Decimal)
        {
            Caption = 'Field 11.3';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure FillData()
    var
        VATReportMapping: Record "NPR VAT Report Mapping";
        VATEVEntries: Query "NPR VAT EV Entries";
    begin
        if (StartDate <> 0D) or (EndDate <> 0D) then
            VATEVEntries.SetFilter(VATReportingDate, '%1..%2', StartDate, EndDate);
        if VATReportMapping.FindSet() then
            repeat
                VATEVEntries.SetRange(VAT_Report_Mapping, VATReportMapping.Code);
                PopulateFieldsBasedOnFilters(VATReportMapping, VATEVEntries);
            until VATReportMapping.Next() = 0;
    end;

    internal procedure LookUpEntry(FieldNo: Integer)
    var
        RSVATEntry: Record "NPR RS VAT Entry";
        RSVATEntries: Page "NPR RS VAT Entries";
    begin
        if (StartDate <> 0D) or (EndDate <> 0D) then
            RSVATEntry.SetFilter("VAT Reporting Date", '%1..%2', StartDate, EndDate);

        MarkRelatedVATEntries(FieldNo, RSVATEntry);

        // Reset filters so only marks will be left
        RSVATEntry.SetRange(Type);
        RSVATEntry.SetRange("Document Type");
        RSVATEntry.SetRange("VAT Reporting Date");
        RSVATEntry.SetRange("VAT Report Mapping");
        RSVATEntry.SetRange(Prepayment);
        // Show marked
        RSVATEntry.MarkedOnly(true);
        RSVATEntries.SetTableView(RSVATEntry);
        RSVATEntries.RunModal();
    end;

    internal procedure SumFields()
    begin
        //1
        "Field 1_5" := "Field 1_1" + "Field 1_2" + "Field 1_3" + "Field 1_4";
        //2
        "Field 2_5" := "Field 2_1" + "Field 2_2" + "Field 2_3" + "Field 2_4";
        //3
        "Field 3_8_1" := "Field 3_1_1" + "Field 3_2_1" + "Field 3_3_1" + "Field 3_4_1" + "Field 3_5_1" + "Field 3_6_1" + "Field 3_7_1";
        "Field 3_8_2" := "Field 3_1_2" + "Field 3_2_2" + "Field 3_3_2" + "Field 3_4_2" + "Field 3_5_2" + "Field 3_6_2" + "Field 3_7_2";
        "Field 3_8_3" := "Field 3_1_3" + "Field 3_2_3" + "Field 3_3_3" + "Field 3_4_3" + "Field 3_5_3" + "Field 3_6_3" + "Field 3_7_3";
        "Field 3_8_4" := "Field 3_1_4" + "Field 3_2_4" + "Field 3_3_4" + "Field 3_4_4" + "Field 3_5_4" + "Field 3_6_4" + "Field 3_7_4";
        "Field 3_10_2" := "Field 3_8_2" + "Field 3_9_2";
        "Field 3_10_4" := "Field 3_8_4" + "Field 3_9_4";
        //3a
        "Field 3a_7_1" := "Field 3a_1_1" + "Field 3a_2_1" + "Field 3a_3_1" + "Field 3a_4_1" + "Field 3a_5_1" + "Field 3a_6_1";
        "Field 3a_7_2" := "Field 3a_1_2" + "Field 3a_2_2" + "Field 3a_3_2" + "Field 3a_4_2" + "Field 3a_5_2" + "Field 3a_6_2";
        "Field 3a_9_1" := "Field 3a_7_1" + "Field 3a_8_1";
        "Field 3a_9_2" := "Field 3a_7_2" + "Field 3a_8_2";
        //5
        "Field 5_1" := "Field 3_8_1" + "Field 4_1_1" + "Field 4_2_1_1";
        "Field 5_2" := "Field 3_10_2" + "Field 3a_9_1" + "Field 4_1_4" + "Field 4_2_4_3";
        "Field 5_3" := "Field 5_2" + Abs("Field 8e_6");
        "Field 5_4" := "Field 3_8_2" + "Field 4_2_1_2";
        "Field 5_5" := "Field 3_10_4" + "Field 3a_9_2" + "Field 4_2_4_4";
        "Field 5_6" := "Field 1_5" + "Field 2_5" + "Field 5_1" + "Field 5_4";
        "Field 5_7" := "Field 5_3" + "Field 5_5";
        //6
        "Field 6_3" := "Field 6_2_1_1" + "Field 6_2_1_2" + "Field 6_2_2_1" + "Field 6_2_2_2" + "Field 6_2_3_1" + "Field 6_2_3_2";
        //8a
        "Field 8a_6_1" := "Field 8a_1_1" + "Field 8a_2_1" + "Field 8a_3_1" + "Field 8a_4_1" + "Field 8a_5_1";
        "Field 8a_6_3" := "Field 8a_1_3" + "Field 8a_2_3" + "Field 8a_3_3" + "Field 8a_4_3" + "Field 8a_5_3";
        "Field 8a_8_2" := "Field 8a_1_2" + "Field 8a_2_2" + "Field 8a_3_2" + "Field 8a_4_2" + "Field 8a_5_2" + "Field 8a_7_2";
        "Field 8a_8_4" := "Field 8a_1_4" + "Field 8a_2_4" + "Field 8a_3_4" + "Field 8a_4_4" + "Field 8a_5_4" + "Field 8a_7_4";
        //8b
        "Field 8b_6_1" := "Field 8b_1_1" + "Field 8b_2_1" + "Field 8b_3_1" + "Field 8b_4_1" + "Field 8b_5_1";
        "Field 8b_6_2" := "Field 8b_1_2" + "Field 8b_2_2" + "Field 8b_3_2" + "Field 8b_4_2" + "Field 8b_5_2";
        //8v
        "Field 8v_4" := "Field 8v_1" + "Field 8v_2" + "Field 8v_3";
        //8g
        "Field 8g_5_1" := "Field 8g_1_1" + "Field 8g_2_1" + "Field 8g_3_1" + "Field 8g_4_1";
        "Field 8g_5_2" := "Field 8g_1_2" + "Field 8g_2_2" + "Field 8g_3_2" + "Field 8g_4_2";
        //8d
        "Field 8dj" := "Field 8a_6_1" + "Field 8a_6_3" + "Field 8b_6_1" + "Field 8b_6_2" + "Field 8v_4" + "Field 8g_5_1" + "Field 8g_5_2" + "Field 8d_1" + "Field 8d_2" + "Field 8d_3";
        //8e
        "Field 8e_5" := "Field 8e_1" + "Field 8e_2" + "Field 8e_3" + "Field 8e_4";
        "Field 8e_6" := "Field 8e_5" + Abs("Field 5_2" + "Field 5_5");
        //Recalcualte 5 after 8e is calculated
        "Field 5_3" := "Field 5_2" + Abs("Field 8e_6");
        "Field 5_7" := "Field 5_3" + "Field 5_5";
        //9
        "Field 9" := "Field 6_3" + "Field 7_1_1" + "Field 8dj";
        //9a
        "Field 9a_1" := "Field 6_4";
        "Field 9a_2" := "Field 7_4_2";
        "Field 9a_3" := "Field 8e_6";
        "Field 9a_4" := "Field 9a_1" + "Field 9a_2" + "Field 9a_3";
        //10
        "Field 10" := "Field 5_7" - "Field 9a_4";
    end;

    internal procedure SetDates(_StartDate: Date; _EndDate: Date)
    begin
        StartDate := _StartDate;
        EndDate := _EndDate;
    end;

    local procedure FillTempEntry(var VATReportMapping: Record "NPR VAT Report Mapping"; var RSVATEntry: Record "NPR RS VAT Entry")
    begin
        RSVATEntry.SetRange("VAT Report Mapping", VATReportMapping.Code);
        if RSVATEntry.FindSet() then
            repeat
                RSVATEntry.Mark(true);
            until RSVATEntry.Next() = 0;
    end;

    local procedure PopulateFieldsBasedOnFilters(var VATReportMapping: Record "NPR VAT Report Mapping"; var VATEVEntries: Query "NPR VAT EV Entries")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        FieldRef: FieldRef;
        RecordRef: RecordRef;
        NewValue: Decimal;
    begin
        RecordRef.GetTable(Rec);
        VATEVEntries.SetRange(Prepayment, false);
        VATEVEntries.SetFilter(VAT_Calculation_Type, '<>%1', Enum::"Tax Calculation Type"::"Full VAT");

        #region Sales
        VATEVEntries.SetRange(Type, "General Posting Type"::Sale);
        VATEVEntries.SetRange(Document_Type, "Gen. Journal Document Type"::Payment);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Sales Payment Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Sales Payment Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Base));
            end;

            if VATReportMapping."Sales Payment Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Sales Payment Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
            end;
        end;

        VATEVEntries.SetFilter(Document_Type, '%1|%2', "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Invoice);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Sales Invoice Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Sales Invoice Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Base));
            end;

            if VATReportMapping."Sales Invoice Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Sales Invoice Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
            end;
        end;

        VATEVEntries.SetRange(Prepayment, true);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Prep. Sales Invoice Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Prep. Sales Invoice Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Base));
            end;

            if VATReportMapping."Prep. Sales Invoice Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Prep. Sales Invoice Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
            end;
        end;
        VATEVEntries.SetRange(Prepayment, false);

        VATEVEntries.SetRange(Document_Type, "Gen. Journal Document Type"::"Credit Memo");
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Sales Cr. Memo Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Sales Cr. Memo Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue - Abs(VATEVEntries.Base));
            end;

            if VATReportMapping."Sales Cr. Memo Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Sales Cr. Memo Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue - Abs(VATEVEntries.Amount));
            end;
        end;

        VATEVEntries.SetRange(Prepayment, true);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Prep. Sales Cr. Memo Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Prep. Sales Cr. Memo Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue - Abs(VATEVEntries.Base));
            end;

            if VATReportMapping."Prep. Sales Cr. Memo Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Prep. Sales Cr. Memo Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue - Abs(VATEVEntries.Amount));
            end;
        end;
        VATEVEntries.SetRange(Prepayment, false);
        #endregion

        #region Purchase
        VATEVEntries.SetRange(Type, "General Posting Type"::Purchase);
        VATEVEntries.SetRange(Document_Type, "Gen. Journal Document Type"::Payment);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Purchase Payment Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Purchase Payment Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Base));
            end;

            if VATReportMapping."Purchase Payment Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Purchase Payment Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
            end;
        end;

        VATEVEntries.SetFilter(Document_Type, '%1|%2', "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Invoice);
        VATEVEntries.Open();
        while VATEVEntries.Read() do
            if VATPostingSetup.Get(VATEVEntries.VAT_Bus__Posting_Group, VATEVEntries.VAT_Prod__Posting_Group) then begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
                if VATPostingSetup."Allow Non-Deductible VAT" = VATPostingSetup."Allow Non-Deductible VAT"::Allow then begin
                    if VATReportMapping."Non-Deductable Base" <> 0 then begin
                        FieldRef := RecordRef.Field(VATReportMapping."Non-Deductable Base");
                        NewValue := FieldRef.Value;
                        FieldRef.Value(NewValue + Abs(VATEVEntries.Non_Deductible_VAT_Base));
                    end;

                    if VATReportMapping."Non-Deductable Amount" <> 0 then begin
                        FieldRef := RecordRef.Field(VATReportMapping."Non-Deductable Amount");
                        NewValue := FieldRef.Value;
                        FieldRef.Value(NewValue + Abs(VATEVEntries.Non_Deductible_VAT_Amount));
                    end;
                end else begin
#ENDIF
                if VATReportMapping."Purchase Invoice Base" <> 0 then begin
                    FieldRef := RecordRef.Field(VATReportMapping."Purchase Invoice Base");
                    NewValue := FieldRef.Value;
                    FieldRef.Value(NewValue + Abs(VATEVEntries.Base));
                end;

                if VATReportMapping."Purchase Invoice Amount" <> 0 then begin
                    FieldRef := RecordRef.Field(VATReportMapping."Purchase Invoice Amount");
                    NewValue := FieldRef.Value;
                    FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
                end;

                if VATReportMapping."Deductable Amount" <> 0 then begin
                    FieldRef := RecordRef.Field(VATReportMapping."Deductable Amount");
                    NewValue := FieldRef.Value;
                    FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
                end;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
                end;
#ENDIF
            end;

        VATEVEntries.SetRange(Document_Type, "Gen. Journal Document Type"::"Credit Memo");
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Purchase Cr. Memo Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Purchase Cr. Memo Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue - Abs(VATEVEntries.Base));
            end;

            if VATReportMapping."Purchase Cr. Memo Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Purchase Cr. Memo Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue - Abs(VATEVEntries.Amount));
            end;
        end;
        #endregion

        #region Full-VAT
        VATEVEntries.SetRange(VAT_Calculation_Type, Enum::"Tax Calculation Type"::"Full VAT");
        // Purchase
        VATEVEntries.SetRange(Type, "General Posting Type"::Purchase);
        VATEVEntries.SetRange(Document_Type, "Gen. Journal Document Type"::Payment);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Purchase Payment Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Purchase Payment Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
            end;
        end;

        VATEVEntries.SetFilter(Document_Type, '%1|%2', "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Invoice);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Purchase Invoice Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Purchase Invoice Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.VAT_Base_Full_VAT));
            end;

            if VATReportMapping."Purchase Invoice Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Purchase Invoice Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
            end;
        end;

        VATEVEntries.SetRange(Prepayment, true);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Prep. Purchase Invoice Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Prep. Purchase Invoice Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.VAT_Base_Full_VAT));
            end;

            if VATReportMapping."Prep. Purchase Invoice Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Prep. Purchase Invoice Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
            end;
        end;
        VATEVEntries.SetRange(Prepayment, false);

        VATEVEntries.SetRange(Document_Type, "Gen. Journal Document Type"::"Credit Memo");
        VATEVEntries.SetRange(Prepayment, true);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Prep. Purchase Cr. Memo Base" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Prep. Purchase Cr. Memo Base");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue - Abs(VATEVEntries.VAT_Base_Full_VAT));
            end;

            if VATReportMapping."Prep. Purchase Cr. Memo Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Prep. Purchase Cr. Memo Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue - Abs(VATEVEntries.Amount));
            end;
        end;
        VATEVEntries.SetRange(Prepayment, false);

        // Sales
        VATEVEntries.SetRange(Type, "General Posting Type"::Sale);
        VATEVEntries.SetRange(Document_Type, "Gen. Journal Document Type"::Payment);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."VAT Base Full VAT" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."VAT Base Full VAT");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.VAT_Base_Full_VAT));
            end;
        end;

        VATEVEntries.SetFilter(Document_Type, '%1|%2', "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Invoice);
        VATEVEntries.Open();
        while VATEVEntries.Read() do begin
            if VATReportMapping."Sales Invoice Amount" <> 0 then begin
                FieldRef := RecordRef.Field(VATReportMapping."Sales Invoice Amount");
                NewValue := FieldRef.Value;
                FieldRef.Value(NewValue + Abs(VATEVEntries.Amount));
            end;
        end;
        #endregion

        RecordRef.SetTable(Rec);
    end;

    local procedure MarkRelatedVATEntries(FieldNo: Integer; var RSVATEntry: Record "NPR RS VAT Entry")
    var
        VATReportMapping: Record "NPR VAT Report Mapping";
    begin
        RSVATEntry.SetRange(Prepayment, false);
        #region Sales
        RSVATEntry.SetRange(Type, "General Posting Type"::Sale);

        RSVATEntry.SetRange("Document Type", "Gen. Journal Document Type"::Payment);
        VATReportMapping.SetRange("Sales Payment Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Sales Payment Base");

        VATReportMapping.SetRange("Sales Payment Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Sales Payment Amount");

        VATReportMapping.SetRange("VAT Base Full VAT", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("VAT Base Full VAT");

        RSVATEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Invoice);
        VATReportMapping.SetRange("Sales Invoice Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Sales Invoice Base");

        VATReportMapping.SetRange("Sales Invoice Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Sales Invoice Amount");

        RSVATEntry.SetRange(Prepayment, true);
        VATReportMapping.SetRange("Prep. Sales Invoice Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Prep. Sales Invoice Base");

        VATReportMapping.SetRange("Prep. Sales Invoice Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Prep. Sales Invoice Amount");
        RSVATEntry.SetRange(Prepayment, false);

        RSVATEntry.SetRange("Document Type", "Gen. Journal Document Type"::"Credit Memo");
        VATReportMapping.SetRange("Sales Cr. Memo Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Sales Cr. Memo Base");

        VATReportMapping.SetRange("Sales Cr. Memo Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Sales Cr. Memo Amount");

        RSVATEntry.SetRange(Prepayment, true);
        VATReportMapping.SetRange("Prep. Sales Cr. Memo Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Prep. Sales Cr. Memo Base");

        VATReportMapping.SetRange("Prep. Sales Cr. Memo Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Prep. Sales Cr. Memo Amount");
        RSVATEntry.SetRange(Prepayment, false);
        #endregion

        #region Purchase
        RSVATEntry.SetRange(Type, "General Posting Type"::Purchase);

        RSVATEntry.SetRange("Document Type", "Gen. Journal Document Type"::Payment);
        VATReportMapping.SetRange("Purchase Payment Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Purchase Payment Base");

        VATReportMapping.SetRange("Purchase Payment Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Purchase Payment Amount");

        RSVATEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Invoice);
        VATReportMapping.SetRange("Purchase Invoice Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Purchase Invoice Base");

        VATReportMapping.SetRange("Purchase Invoice Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Purchase Invoice Amount");

        RSVATEntry.SetRange(Prepayment, true);
        VATReportMapping.SetRange("Prep. Purchase Invoice Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Prep. Purchase Invoice Base");

        VATReportMapping.SetRange("Prep. Purchase Invoice Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Prep. Purchase Invoice Amount");
        RSVATEntry.SetRange(Prepayment, false);

        RSVATEntry.SetRange("Document Type", "Gen. Journal Document Type"::"Credit Memo");
        VATReportMapping.SetRange("Purchase Cr. Memo Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Purchase Cr. Memo Base");

        VATReportMapping.SetRange("Purchase Cr. Memo Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Purchase Cr. Memo Amount");

        RSVATEntry.SetRange(Prepayment, true);
        VATReportMapping.SetRange("Prep. Purchase Cr. Memo Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Prep. Purchase Cr. Memo Base");

        VATReportMapping.SetRange("Prep. Purchase Cr. Memo Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Prep. Purchase Cr. Memo Amount");
        RSVATEntry.SetRange(Prepayment, false);
        #endregion

        #region Deductable
        RSVATEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::" ", "Gen. Journal Document Type"::Invoice);
        VATReportMapping.SetRange("Deductable Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Deductable Amount");
        #endregion

        #region Non-Deductable
        VATReportMapping.SetRange("Non-Deductable Base", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Non-Deductable Base");

        VATReportMapping.SetRange("Non-Deductable Amount", FieldNo);
        if VATReportMapping.FindSet() then
            repeat
                FillTempEntry(VATReportMapping, RSVATEntry);
            until VATReportMapping.Next() = 0;
        VATReportMapping.SetRange("Non-Deductable Amount");
        #endregion
    end;

    var
        EndDate: Date;
        StartDate: Date;

}
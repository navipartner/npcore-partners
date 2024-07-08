codeunit 85162 "NPR Library CRO Fiscal"
{
    EventSubscriberInstance = Manual;
    procedure CreateAuditProfileAndCROSetup(var POSAuditProfile: Record "NPR POS Audit Profile"; var POSUnit: Record "NPR POS Unit"; var POSPaymentMethod: Record "NPR POS Payment Method"; var SalespersonPurchaser: Record "Salesperson/Purchaser")
    var
        NoSeriesLine: Record "No. Series Line";
        CROAuxSalespersonPurchaser: Record "NPR CRO Aux Salesperson/Purch.";
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        CROPOSPaymentMethodMapping: Record "NPR CRO POS Paym. Method Mapp.";
        OStream: OutStream;
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := HandlerCode();
        POSAuditProfile."Allow Printing Receipt Copy" := POSAuditProfile."Allow Printing Receipt Copy"::Always;
        POSAuditProfile."Audit Handler" := HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Do Not Print Receipt on Sale" := true;
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sales Ticket No. Series");
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
        POSAuditProfile.Insert();
        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit.Modify();

        CROPOSPaymentMethodMapping.Init();
        CROPOSPaymentMethodMapping."Payment Method Code" := POSPaymentMethod.Code;
        CROPOSPaymentMethodMapping."Payment Method" := CROPOSPaymentMethodMapping."Payment Method"::Cash;
        CROPOSPaymentMethodMapping.Insert();

        CROAuxSalespersonPurchaser.Init();
        CROAuxSalespersonPurchaser."Salesperson/Purchaser SystemId" := SalespersonPurchaser.SystemId;
        CROAuxSalespersonPurchaser."NPR CRO Salesperson OIB" := GetTestSalespersonOIB();
        CROAuxSalespersonPurchaser.Insert();

        CROFiscalizationSetup.DeleteAll();
        CROFiscalizationSetup.Init();
        CROFiscalizationSetup."Enable CRO Fiscal" := true;
        CROFiscalizationSetup."Signing Certificate Password" := GetTestCertPassword();
        CROFiscalizationSetup."Signing Certificate Thumbprint" := GetTestCertThumbprint();
        CROFiscalizationSetup."Certificate Subject OIB" := GetTestCertCertificateOib();
        CROFiscalizationSetup."Signing Certificate".CreateOutStream(OStream);
        OStream.WriteText('MIIaJAIBAzCCGd4GCSqGSIb3DQEHAaCCGc8EghnLMIIZxzCCBXQGCSqGSIb3DQEHAaCCBWUEggVhMIIFXTCCBVkGCyqGSIb3DQEMCgECoIIE+jCCBPYwKAYKKoZIhvcNAQwBAzAaBBQUmQaCZOEvS1BJcAUslUtFU97bdwICBAAEggTIpFOAR4KbzjosVv8LPQmwkgcxjhAJbPEBFZA7kRGiIv+9lNG83bvBCtTlJRoTzALFtMcmpZhrVnRrL4ShgNnceKvSZyGCZJlUKqzRpqwOzdfTwEtqDIT9XIinmyG9qRL3lN3wYLV5IVOur8O7ejg36rQTeSzin6PNkgxHcAnIRqj2LnN9AbkAdWP645PbLvs7XXXEO7b5TMvZSgxWeR3ya68fRV4r+NuV20bBQnV6TpK9FokCSOr3QsHHjTda74fEhzfWrbY6Y7CusDRhDk9bId0S62cqA+kLT/ElYCHYAXi97urqoP7EQxEuCu1H6YyifhzWBqRHFpnu92ZiOA0L547Y4yU9AZKFFcFoaCRPVvlnfHFW2etWqDG5ZXoA7zgMft3kwUs4VUm4C8pmxGxpTNDe2qeb9Wmr/GiIii1Zao7FgLlbfPxZMaqnrOsypAjtM+NxItK1eXrH0x9aAB4EZAATQBfxOVlQQMGFpvqahXJYVINextDoOtaMB+XSKCe7GDsAh3YxN28tFiv8Pz3QCiTpoU8c0vGTzryyVYPdeKhNWNXaI1NlRDHhER3GAOXwVOIKeCvdrZCFl3z91oCJmhUDmFF6Ekxoltrh/e0H0pWpejwqR9RHmp9EKnqaxhsoGwNHq3jT5tgSQKs9gh4bSXpbuI0mFdv+sLVBNbAFR70cfmuw9Up/S6Gk89014fCfp9OE6S6lvR2Qkl4Z3gjoh0A6IJt7S8he/1tqmc0aC/7J3gVQCSxeS9/VXV9XZoiG1YLzcs063kXc3xvT92B7Oe9nIrLh1y8Hfmp41ajs/zcpAgKHITLGraMApXBfXDZ2wz1V04tP+R7ygxVvY8i6E57ycnEFLgZ0NfS8xoNyKHhbLLiEtWj8bRKeTIE6tktdm5RSJmoZYOiyPRzhTvkbKJzYySmZR7bz95x35jWecSg3T4sqNHNps/NKaEWMy106qNj6va9leDFwODktRk4P7YW+MEm0a0Y5i+CVT7q2Vmswt3AJ4JnVtffGpvcvchQjzjka5kerdCECxGa9aYkMPMvz6ZANQpIZuiAuwQ2B4VwXda9NmXXy52E9SuYMTzRrelMKCEPTHdZFLpwnA+JWNnBr7ZI2KaQmlZHhe+i61Sj8L4WYvgFtIKi12GGxnt//jHQRIyGLDkmmLxsAfpu74xPlCiGkMJcgkkttQzdoaLUJGpf5KLQtFmFE0at6ZYrG/8ijLo3QGzshw14nQs3gpvHRxYQ1nxfPhCmADzWP/sFoHad0FXnkzyTTRL/jHxOIOkiGFublCXUnpce9SqdcKhObx9KTT4sVksCLYPMimIUa5E6qaLkopR4IPB39YYT2pNgYcaX8yZGxuNhFlmkvmSt58Chf0Pan3kFfiTUr36A3+YqXaQThSxY/FLwDgdyJ2c2rzvMmn+1Bq303WvohY2BihdL0+DkLe2U7oP3xYPgDYbIHfH6d7nfkaT5qxZezWd+OC2CNQ6yr42tX/Bzk4B0skrr6r37zLUYLSFIkmMRnaJZBc5DvocboVoIrj0C6yIX9gmFHzrBh/n8r4sPMFz1hP4/xcbK6stET/1qPqTk5BSN38W6gH8G4lXcOYPQG7aPNVPQ/1LuzRXpAIhBroiqGBBSS6WisMUwwIwYJKoZIhvcNAQkVMRYEFHH14ZXad8Or9HVKz1WyIO1PQDEnMCUGCSqGSIb3DQEJFDEYHhYAYwBuAD0ARgBJAFMASwBBAEwAIAAxMIIUSwYJKoZIhvcNAQcGoIIUPDCCFDgCAQAwghQxBgkqhkiG9w0BBwEwKAYKKoZIhvcNAQwBBjAaBBQi0p9ptLaA0oC57v07LBB0na02jwICBACAghP4cuskM1lwF8GIUcqe51qrPLxpYjTDeV9GOJ6/JpdDHE+SV9Fmu9c2N/MOeso+JILh8n83jwFOrN3Co4rD5hVuJgKfQiLqfBQl0f82H32TI2sCh4N1uuCHFJ2tTbtqcsYiL5xsF3GoS86/7kRXpDq400wZRI63mev1CAz0N+Di2dJHKrctbdzU/prpmD0eHdIDEoDElvFb2yy5+1Y0wha+hobcX2rxZq5yjMBWUUQKTWWp/ECcxkKIFcuvFiCl624T4wbpggKYb+U9iRjGJnt3pNM9r7RCnYajQvC+NqfJv2Kw5hmUXK/GtK07eoXE4TfcUQo3HtvW3vLUm83/CkScVwBWBW0gu1Eqe1Kf3095LoPnHzBwS2JyACyu8wG9Db1E7rlMR2xaLQT7BoGLafuO3p/orkw8Mzd8Ch6z+MfPfGmnzUZTsb0R+XArdsGta+pidyaJEJXM44ryvoC6QdA5PxjEtCwIxNEwUJvCkmGb2EgoKXv9e83phCtJT278Ww/1CEcpbINW6qWM+Ygtj1cZRVBnKi7zDseZWG+Pn5fkUDgHrOfaZFEqM74/tbEy7Q/+ZavaQ+H0W1KLyxvQUHAj6UYAGTAGRySXC25d/F3wPngcAXIvi1K6WvshXn3xqvZtnBqHAoxIuNuMZjxWl1ZnG3CtLUmi6dLOeO3xMVy0SKPbMdeSSNEX5+as/E2BAzLYl76skA/vJxDGvgawQ09Pj77lhipkEsnUglzlur9boyf69XW0dx9VVe7cT8gXeplrKGZeXFiDH8S28qG4NG9Y9URNwdRbvV6RMEK42lhiwmYkh78T5H3Y9cIzJe3boZEw/lS9uXPZPzPHD6a/Vx/OmzbW1M4hdY8t1uX7duWWncrUQ5+yrWUplCPilDFghk6PQhVRgTUm15vuW/Svv6Llyt82r/+bcCRAeyqzg+bjz2XkaefZZKPY2nC1X0iy4kBr0lMutf7ZeUWpEsdjUNvPoyAne0nzjOXZYsDoEmiWeMP3q90a2k8UIYXayccLkKLhe0nhoWNE+RnpekYBudGCSfGBFLTAbG305OMQf4GdOH9nIWnFiKREe3GSkNPNjCZ1FlRiGQr29ysSVc91OkWc6Rh5/SBRjlpmNORqs75cIBoTefM8KXd/17HXVjTfLjn70Vqmhtxh8EpHXnifiN39DnPsNp93EZLIEYKPqC0OxQ0h7rMslHvf1B/6x638VgwilGJ5p6+BQcfRDfnWJGtINMOhSP0RJu1Pm3+cZyjedstZPDmF3u+GIWpEjvYsmYYnxfVsnwCjcqMl2g/TSxBDBZ/KYdZ0n5jW6VqWt2dz3fnoPxjR4BWgn38Dwyui12YL/9BmC0Z49zVyWFsUG9h9TakmBzVccwDBlcb7UvMHhAT42NvTE50C7OiCXvWml5i1tmTHkLyFyj1GFlQiAxk9at/8N7yrNbcSVE+oKBqOhH5O27F8r4smTHxp9sAHXGme1rwhRPoMhi5hjxd+VDrCyjekfvHBEbJCe5c5p2AfbCbLMIqczfAnlaWxv2zYWZf8IwSNDilfgdVbsGS3V71gq01kUmgXAzuX9T6Tcp0OQEJBe1OhqhqqCjfhAuxqxRRxuNmPU0xgjLwK1sp2rik9ts6p0KlrFiMDeE361i0SqGk6kpNlb/RPrtd9Fmvkky7szlCeJXGYNBMfBIwf6037JAEyFWRfyw82Uxx3DtZTiBcQIbo9qgyC9vvFagrlKzQmEkxqqIMocVvCjNee/2zgtpCAL6iQk2HxgokjRQOeL2wg1mI8QgErxXdqFjH9UVD5pnKEeyulZqV4H13VhnXLtpdicRhIySurRfqErnS3fbv9vy+14SUsDpcRqIiK87eS1WLTvDm69RGKuXsjkzC2OrNs9fmMuTnyH1u9LbPKNoVPideV1BmRWf4qcn1PvrbnHvkkTcd7S42px8VakZHBXF1amNzheuNQ/IeivEFjWtvnfmi1FmJ7nRlLuSuQeQvj9bu38b4Z+HEBQ/JwkYFLX8k8CTFuQctI4PqZFao/hn+HF0RURCKhthl4ktmwwC93rc8bYXi47ifHyInJvZq1LwgbrQ/S6bF2C2k5D5CwubQPrj/WzP3RdjDeLzHvrPd8RxAmaT0o42UUDVnQN3PbRk3sFD1/LoX9YU0SggXhAvKe18rmezkQ8XDDtoc7AMicE+gSJ+IRYqB7iPfd3fFoQpQ5TAoSsC50QcNMYyemGboTHOJJUXPvriJij52gFNSaG/3RAUYAJYGaKAZkkIQDXNocAIg4yCG7a20Ypi/KaDSNrpyRR+4nvhbgWHkzTtC8yiZ/WjOWAS32HJuscmtrvjE7CkacTfBR308UV0j/yLj7Fcb4mT/6ZdV7WsKDPRx/ZQmATGs+pwofO3jSOO1TnmUDQG27hC4R/hR+CUVifdqkweL0qHb6pdHDxOE8ScFAWyd2GzziT0fY0OSUrSFKVe6lxF/rKLV2zTKsUEx5WpIzATnAraGFj44rTkRP8jinwwKrE6DryofUKqOI8uHsaP5SWPUePEbBEPZ9p/0g6LPndXrTzwXNmrrDgO7WnxXZ88BVXMXwkEFECsVf2bIVeuVMjAqTr+goICL7O04lfCvWp4falfkVMJlEo6v4+heWMrOzSkPPBhFLc5tMyY6CTv8G/BxZWSTqSZnhdcV4Lm/2C2ej+030c9wcPtVcr0meVsdw0zDIF6tJaNHU/V7C0+h6sJItLs1cvV81oh05pjyY5UK5u+i5U9E20grhXyFu0BabwMdaW/eI10Q4WndIBrNaPjpc2GStalD60C7phwYvkbwSkK42849o8BJeay79fYby/D3CPs81e+1K3hib+OhbUcdnar449JOX5p8s8tfSEbcJ+H4HLlrh7vLJzz7cmL5GORN7maFdQ7mx4AdVgWS34/au1pR27FtLPqXVbNLwQMYZFSWxH3AKDPaH8Qr6Oyh08JaAMZmdHK7s+aSabL0FLIrocCS68niyIskgnZsPve039VRUUHoLZXHdONOUN1tMWGdAXkzrY+Wfh/0B6kMv2V13zbwXI25rLJth1LlXAqjTW5uFinhQ73YAUvwKsodW7dDDvu/z+7yKPCI7f+nAdhuXNPhvfr90pybWvVAPEti3HG8v4NlCWWO1hCI+sCAXJ5fcNqlxlnPvwPv1Ot4ThSE3WgqB6oUeofaZGbKgWxMyvXjyXDRAVcquT+DqrFeShpqDU70GUcV+ZPzUTcCSqkd+Iw2C3WUqJK8m6aXcfrXw4pyK/42tvrZrljZiZZCem+yd5WEIfR/m0rHXKtFf+9+2Aiz7JIKi3npFX3ml0YPf9/MleNOBB6INnmvbtgIQzOh9c7JUUQTytcxiphqA1J1Al6QchjZ0XuAGuaRDVQ+HF7dn54s/aUjM1Dc8SPSXgLyMU5wgAsMmwACjr5s7+CI6YS7D8lFTBserUT8GoTAhQMkHyN3MGQ8kfEK6uwiooTi9ZdsCPaH4QZbueuJ+zeVsQejwbPCbwBCSM2V7dSJLSpOBLYaIzyb63eEuWFICjtVQH93wzd7fIyjwIB4RJnXMZb/9N9rCY+6IVivEcSXCY4KsZ6LB36mViII2BKASEYdBQHd7ZvP0x+4aqPthhNkgHOMWpitFQLgcqqC0oBFxFsFyIe6BWtKCVPJ0g95OuBKgn1SsFkqZoybVfQjYJBFSN5U7msuKzoxa2/eNBgVqq/6qs1c+j2BaE8ltPXybPQeMbxe39U59WKI1bdxBwO3ZToIW8WbfmNbZywuw5OU1RdGJe4CgsFOEWKnaPeb1FDQZwuOXSYXkorEwOuwlel914h4f+v5w4gqHZIDkoijQ4mPh83j2JLl7YZjIAJu4O8SGuc40/MhxkwR3LzRucU6yDddXHqYs1HChO3ZHXy98ExItXgJ5TTcgsywL8x9qfIEoCbhm0nGuWIbgA+LtUpQ9wb6Kr/W3q7mukIn39G4yuCiXEW09GrtbybN9Z3cuPfdai+SgkHLHroyKFdB+SVpzY/p28IU54iXUvVsvMdJSNQXpLeIAWXdsZhGGgcTno4F37WU0T+DVSQADgHYQ8pD5vO7d7h7ojHN3Yi/jJ9crBvPH35zORFrXaKMwyv0ekn0FDjoGvOnRYtz7tPEwgWkYL2DrBPiuqcqQvkE0TyqrjWvZT+AzUnkDQITgyeXXMRa517aNpJ31kFH9NabiK3Az0eP6Y1SJQUbEWXPx6BT/A+J0gpBsjzOMfvRgy7O8FO+gNNOc1BCNYZys7Q5CvP64OpZSRVtq4VqUEhn3d0unHsm88S5pj204TvQO0sh2O8iWkGOYVgymQ9Iytg9LtPL+6dgTLkquZVrN1U+hE7atgNNEgymaIhMt8/fhV+kSUYxm1LV4S7/ayRJsiYPb4VHBQyb5ogDJ4QfJxAlaUlVv6khqaiqgio+9laF6/vLMwXOlLacXItWxJS3vK0TqcvGWINyHhHH4cjWKrN3b4E8oJGXPqO3tr2lMESeIXNnGkEKwiRQcHWfv5/IQGO64GTHbNW8UlQKv0heNMa/BSYXfs6H+5cp+HfYfJSCxV1Oaez4+7QiSjglktOvznIc8iVUBkH7SnkS8aOoe1lH2vzdm02f5nyNtYn3T5p4JH746FWU3npXeEaEJXRrU+JP5+ZKqRzmITWoSYJZR+UVvYervKSDP/3wihCLv0hVnsk413ud89Xq2YMewX/M3euM2jDcw7m/wkK7bsQkCtl0LGJqAucP0TB08C4XKR1Sxgqa9F8zNH0iCkFpF/nK0OS+Lm794hYvIOzJ2heiY7h5NXZ0QIs4S6yJcF0Fehq4DdUfwLMZVU/I32nFoSF8WSxQiQtWOHXkr93SYK16ADhM0H2z5agrFn0u2Cbr2TQE26514/C+dt5CcsOAQ/DE76sPeKB5oipKy3HhDA7v+8x5PS5j41vfPUy55iorErBoFbCJS7xCg1hz21H2P3xVtmIfA8Z2cRrc+Y1v7vCHutNxFgW0Q87ie0Ju77aKdK9h3Aha1wToFYz094ObZUO4rZLXfmq6DflgumDenQtI2frc0LO9hjlXmT0M5if0bonPcJhocdZobpE2za1ji8Hf/vAOcYtCQDTsHeYmf/+kxxEmu8Ae9wDSXZhxwpXNliKNH+by2eIJ0VCxBDGSmAn6Jc3CPbNqRDVEO7PqBk+aZNBoluingDNcZvkUR8zMAvI7GQMKrnyKbX5ewHv8YNvR/hfUREib9i6/ZZP6d8xLjmdd5tJfMYOSnUtRykbOO2bpDYIlQd1DMhKZ+VdZopIt95R7SnfGouyUGWNtN/eBaK04Y+kozQg/Xpd2OvYGwgl2GhrQ8AK5Xvii6E8IMa88ws/FwwfbJyTEEKMMWZBsZMfM11CsxXv5qRpWEHVavdPtL+IWeHKvmnlf3ci7vHHqdJFJ4RL7v8rYB03QRV9h2gvNsEfchyI8vWEBULZKVP+wsd9JAE/uXm2UYvevnbeIZnszoFUJPG25axAcXH2xYLRysr4eOaHi5lunfPc7EUUqyebehsraLKPfRRwKi25pI2tP1s6XEQZYJs6Bm1WTiCjG3wMqDA2GR45iloFOXFKdBrWJW2hVk6yFJYRK8DwwZ2cAA6dgScVpXoLrg0lPQEJZUs20W8lnBmdHEgUZ41U915HkYnjrOa1JAQXuQyeJlwVfDBDXXx7OU0ZbdfDnnpP7aSrJq/hS3/RuOqRgVW0f4ugHfLfgyeeiWxdl0cPRYzlMws8D5Dp1ob1VipufN7+b+ckFl26GEvEwfO3eUreqjM4yqddIFoF31CUStKLF5RNMhPTU8casA9AxRP6Fbhky5F87kPs7PFhMTLMdjWlXZLq4VUQUrCXGKgkS4NYgthNZ7Y/yJspGnxQkvlrpkkmI3bIgnVz73OxtABWX15xFnG59bmqT+pLpyed2S3g6zZvyB95paidT3DhWA9blZze8wpFBNZYk7xVlOQ6D6Krw+3XV96Ou54YBBSIWSYDj96l1lhUz/uujBgA6fgkW8L4n1OJd05BdRIu+6S4NRiXplxhMzPV8iHWQ4LWcenwAPMbJQvECfjk1fMkolk3UGzfSDgC8KadVyqGmAuc/TeNt0BfZJZplexSipjOzTd+VBhoHaOu/5qJzYfDE0sYUhnJiU52+caU8qAxZEloq56cVylERjPEngLKpY8Vk7I3YTNPHg0p6V3ul2CW1DZqOuKPnAP79/RL0jJHqm/aUAwKygIA/PnhLWwe8fw83ybb4eXo4NxwxAXrMm1NvMO4y/OjS6OiutMKHi6DYdyHo9Y9Z3rDF19rGv6CtJS9hKgjRc6KeHVPrHcjj9PvAVnpGTOf9FcSENzr8n21AjX6ed5yxcPU19rFrDh5xR0w1i6LKrFezSnI7J5P/ze9phSrV9By66ftJvdCmi673nfT/sqSAGVjKEnaLYoeBpRXiHJ0U5NqqLEeHsO604J3PBQI0gt1DmKGfSriEvgJH+ZBbiaexascqoBTIwZ43WeC+trMG3PetSi5iNgMO19UtRIH3DRvonn7OUFJFnwiUDwVU//cdfosPnQP47g6MfKqd/hXQjYXxwBtQ+nLXzkJRgUx7ZA1QX/ixBcbbTa/JxVVc5caLxkCEDacVwqjS0b1Kz3SHYtITjPz8TewbxHNrf55tq52lqbU4vbCvvhhOLmUgsrk+PM7n+SlAHqZ/gZ7MciQQAd8/eeCmQ1DZuouu0kxdNpsrRPTqVM8nKpghtfiuddB3AWwGpiPxL/kNAl9lK/ZwlaEyC/zN74jSe5kqnczWgAyIg/NpW0JqyQqvnzIqAox/6yhEKANsIamuS8ZRPPv/T919ac0+Q/BmfMD0wITAJBgUrDgMCGgUABBRvhYt411Yvt8w9Vl3RyDi2XRNbswQURAr1m1X1ztWn3TCsamx3K/zJOI0CAgQA');

        CROFiscalizationSetup."Environment URL" := 'https://cistest.apis-it.hr:8449/FiskalizacijaServiceTest';
        CROFiscalizationSetup."Bill No. Series" := CreateNumberSeries();
        NoSeriesLine.SetRange("Series Code", CROFiscalizationSetup."Bill No. Series");
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
        NoSeriesLine.Validate("Allow Gaps in Nos.", false);
        NoSeriesLine.Validate("Starting No.", '1');
        NoSeriesLine.Modify();
        CROFiscalizationSetup.Insert();
    end;

    procedure CreateNumberSeries(): Text
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'CRO_FINA', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure GetTestCertPassword(): Text[250]
    begin
        exit('Factor1al');
    end;

    local procedure GetTestCertThumbprint(): Text[250]
    begin
        exit('32F3BD781541E93278043E6509E3C7E4CA2BCC8A');
    end;

    local procedure GetTestSalespersonOIB(): BigInteger
    var
        ValueTxt: Text;
        BigIntegerValue: BigInteger;
    begin
        ValueTxt := '11129995674';
        Evaluate(BigIntegerValue, ValueTxt);
        exit(BigIntegerValue);
    end;

    local procedure GetTestCertCertificateOib(): Code[11]
    begin
        exit('31049485535');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR CRO Tax Communication Mgt.", 'OnBeforeSendHttpRequestForNormalSale', '', false, false)]
    local procedure OnBeforeSendHttpRequestForNormalSale(sender: Codeunit "NPR CRO Tax Communication Mgt."; var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var ResponseText: Text; var IsHandled: Boolean)
    begin
        ResponseText := '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:regexp="http://exslt.org/regular-expressions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">    <soap:Body>        <tns:RacunOdgovor Id="G0x7f9c5dc0e500-4D" xsi:schemaLocation="http://www.apis-it.hr/fin/2012/types/f73 ../schema/FiskalizacijaSchema.xsd " xmlns:tns="http://www.apis-it.hr/fin/2012/types/f73"><tns:Zaglavlje><tns:IdPoruke>e8276707-e928-4ea5-aea5-44c42ee402f8</tns:IdPoruke><tns:DatumVrijeme>18.10.2023T14:54:30</tns:DatumVrijeme></tns:Zaglavlje><tns:Jir>f38748d1-d3fb-4b08-ba1b-14118c9de444</tns:Jir><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><Reference URI="#G0x7f9c5dc0e500-4D"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue>zUxsKA5gfXp84ziGt2ybADspi+c=</DigestValue></Reference></SignedInfo><SignatureValue>CxpHEXMOP7A7vtQ4ZnNJHSidmXIO560RUu/kWi5qaeQpl7ITA0Zsy1fzIT9dRZYTFiUo/05yHqCp1pBWu8nFCE4u5NHd01tnSTCXEGmeGGAkRMPUZ5I6smF3d2fP/FHFBWCas93JX+qhVLTzOxJejEUlWhQIQN6Ym+sbiBtYqm0zAXcaATyK1Y+tSfHqO6LIHHZwrEAoG6QHNsSZ/4VUhRQxyOkNbzFSIjP2UepBkckjJFL4LLyNFETUByDouXKKn5wYqO3IdPYsUbC3/MpevOgNKRvD3+HxwAL4oZ5RIzFcFn9c29cIE1cv8dCccPz7iw06eUKUZLwXl4OZcKtLYQ==</SignatureValue><KeyInfo><X509Data><X509Certificate>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</X509Certificate><X509IssuerSerial><X509IssuerName>CN=Fina Demo CA 2020, O=Financijska agencija, C=HR</X509IssuerName><X509SerialNumber>163622941396977276140732476819071330045</X509SerialNumber></X509IssuerSerial></X509Data></KeyInfo></Signature></tns:RacunOdgovor></soap:Body></soap:Envelope>';
        sender.TestGetJIRCodeFromResponse(CROPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR CRO Audit Mgt.", 'OnBeforeSendHttpRequestForXMLSigning', '', false, false)]
    local procedure OnBeforeSendHttpRequestForXMLSigning(sender: Codeunit "NPR CRO Audit Mgt."; var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var ResponseText: Text; var IsHandled: Boolean)
    var
        XMLSignatureErr: Label 'Error getting signature value.';
    begin
        ResponseText := '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><RacunZahtjev Id="RacunZahtjev" xmlns="http://www.apis-it.hr/fin/2012/types/f73"><Zaglavlje><IdPoruke>e8276707-e928-4ea5-aea5-44c42ee402f8</IdPoruke><DatumVrijeme>18.10.2023T13:26:18</DatumVrijeme></Zaglavlje><Racun><Oib>31049485535</Oib><USustPdv>true</USustPdv><DatVrijeme>18.10.2023T13:26:07</DatVrijeme><OznSlijed>N</OznSlijed><BrRac><BrOznRac>1</BrOznRac><OznPosPr>GU00000027</OznPosPr><OznNapUr>077</OznNapUr></BrRac><Pdv><Porez><Stopa>25.00</Stopa><Osnovica>8.00</Osnovica><Iznos>2.00</Iznos></Porez></Pdv><IznosUkupno>10.00</IznosUkupno><NacinPlac>G</NacinPlac><OibOper>11129995674</OibOper><ZastKod>0d9712ec113a98d8b69eb5543c912a02</ZastKod><NakDost>false</NakDost></Racun><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#"><CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" /><SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" /><Reference URI="#RacunZahtjev"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" /><Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" /></Transforms><DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256" /><DigestValue>m2ORdzp9/bfmLQ7T7GBzOKtNb9gu7gtltDRmiqUku4M=</DigestValue></Reference></SignedInfo><SignatureValue xmlns="http://www.w3.org/2000/09/xmldsig#">nm38JOILLOtoz2j/dG7snPrFj12xc4UXhHvfpQiwk02AiyLyF5NO8F1LzILvLS08CkLX9o53rsz/sUZiAoGpUTNuyFrHM6mSONO0YOb/xSq8km5N5tIyZHY2izbpczYzVmQmvNBlAEozkGclwnrz9HDRLaQVFYHAKZrjO0DDTZDXQKZWzKmrTK7Xe/dwkQSS5RNCNu6LvpNKKqYtn9gEP/mICcBKzEUa2P94y4AXtANBTABj36/y4I+T2hKzEfuREzRqJMVoArL4p+XUZzzP8LA1ZuIhpis4i2V+Tux2I8oFvaThLb0kFTSibgaGphxHRD01c2CLbVSsN66JSl1kQg==</SignatureValue><KeyInfo><X509Data><X509IssuerSerial><X509IssuerName>CN=Fina Demo CA 2020, O=Financijska agencija, C=HR</X509IssuerName><X509SerialNumber>146499516297812039282158123834814014355</X509SerialNumber></X509IssuerSerial><X509Certificate>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</X509Certificate></X509Data></KeyInfo></Signature></RacunZahtjev></soap:Body></soap:Envelope>';
        sender.TestGetSignatureFromResponse(CROPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR CRO Audit Mgt.", 'OnBeforePrintFiscalReceipt', '', false, false)]
    local procedure OnBeforePrintFiscalReceipt(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR CRO Audit Mgt.", 'OnBeforeSendHttpRequestForSignZKICode', '', false, false)]
    local procedure OnBeforeSendHttpRequestForSignZKICode(var ResponseText: Text; var IsHandled: Boolean)
    begin
        ResponseText := 'e4d909c290d0fb1ca068ffaddf22cbd0';
        IsHandled := true;
    end;
}
#if os(macOS) || os(iOS) || os(tvOS)
public enum Language: RawRepresentable, CustomStringConvertible {
    case af_NA
    case af_ZA
    case af
    case ak_GH
    case ak
    case sq_AL
    case sq
    case am_ET
    case am
    case ar_DZ
    case ar_BH
    case ar_EG
    case ar_IQ
    case ar_JO
    case ar_KW
    case ar_LB
    case ar_LY
    case ar_MA
    case ar_OM
    case ar_QA
    case ar_SA
    case ar_SD
    case ar_SY
    case ar_TN
    case ar_AE
    case ar_YE
    case ar
    case hy_AM
    case hy
    case as_IN
    case `as`
    case asa_TZ
    case asa
    case az_Cyrl
    case az_Cyrl_AZ
    case az_Latn
    case az_Latn_AZ
    case az
    case bm_ML
    case bm
    case eu_ES
    case eu
    case be_BY
    case be
    case bem_ZM
    case bem
    case bez_TZ
    case bez
    case bn_BD
    case bn_IN
    case bn
    case bs_BA
    case bs
    case bg_BG
    case bg
    case my_MM
    case my
    case yue_Hant_HK
    case ca_ES
    case ca
    case tzm_Latn
    case tzm_Latn_MA
    case tzm
    case chr_US
    case chr
    case cgg_UG
    case cgg
    case zh_Hans
    case zh_Hans_CN
    case zh_Hans_HK
    case zh_Hans_MO
    case zh_Hans_SG
    case zh_Hant_CN
    case zh_HK_CN
    case zh_Hant_MO
    case zh_Hant_TW
    case zh_Hant_HK
    case zh_Hant
    case zh
    case kw_GB
    case kw
    case hr_HR
    case hr
    case cs_CZ
    case cs
    case da_DK
    case da
    case nl_BE
    case nl_NL
    case nl
    case ebu_KE
    case ebu
    case en_AS
    case en_AU
    case en_BE
    case en_BZ
    case en_BW
    case en_CA
    case en_GU
    case en_HK
    case en_IN
    case en_IE
    case en_IL
    case en_JM
    case en_MT
    case en_MH
    case en_MU
    case en_NA
    case en_NZ
    case en_MP
    case en_PK
    case en_PH
    case en_SG
    case en_ZA
    case en_TT
    case en_UM
    case en_VI
    case en_GB
    case en_US
    case en_ZW
    case en_CN
    case en
    case eo
    case et_EE
    case et
    case ee_GH
    case ee_TG
    case ee
    case fo_FO
    case fo
    case fil_PH
    case fil
    case fi_FI
    case fi
    case fr_BE
    case fr_BJ
    case fr_BF
    case fr_BI
    case fr_CM
    case fr_CA
    case fr_CF
    case fr_TD
    case fr_KM
    case fr_CG
    case fr_CD
    case fr_CI
    case fr_DJ
    case fr_GQ
    case fr_FR
    case fr_GA
    case fr_GP
    case fr_GN
    case fr_LU
    case fr_MG
    case fr_ML
    case fr_MQ
    case fr_MC
    case fr_NE
    case fr_RW
    case fr_RE
    case fr_BL
    case fr_MF
    case fr_SN
    case fr_CH
    case fr_TG
    case fr
    case ff_SN
    case ff
    case gl_ES
    case gl
    case lg_UG
    case lg
    case ka_GE
    case ka
    case de_AT
    case de_BE
    case de_DE
    case de_LI
    case de_LU
    case de_CH
    case de
    case el_CY
    case el_GR
    case el
    case gu_IN
    case gu
    case guz_KE
    case guz
    case ha_Latn
    case ha_Latn_GH
    case ha_Latn_NE
    case ha_Latn_NG
    case ha
    case haw_US
    case haw
    case he_IL
    case he
    case hi_IN
    case hi
    case hu_HU
    case hu
    case is_IS
    case `is`
    case ig_NG
    case ig
    case id_ID
    case id
    case ga_IE
    case ga
    case it_IT
    case it_CH
    case it
    case ja_JP
    case ja
    case kea_CV
    case kea
    case kab_DZ
    case kab
    case kl_GL
    case kl
    case kln_KE
    case kln
    case kam_KE
    case kam
    case kn_IN
    case kn
    case kk_Cyrl
    case kk_Cyrl_KZ
    case kk
    case km_KH
    case km
    case ki_KE
    case ki
    case rw_RW
    case rw
    case kok_IN
    case kok
    case ko_KR
    case ko
    case khq_ML
    case khq
    case ses_ML
    case ses
    case lag_TZ
    case lag
    case lv_LV
    case lv
    case lt_LT
    case lt
    case luo_KE
    case luo
    case luy_KE
    case luy
    case mk_MK
    case mk
    case jmc_TZ
    case jmc
    case kde_TZ
    case kde
    case mg_MG
    case mg
    case ms_BN
    case ms_MY
    case ms
    case ml_IN
    case ml
    case mt_MT
    case mt
    case gv_GB
    case gv
    case mr_IN
    case mr
    case mas_KE
    case mas_TZ
    case mas
    case mer_KE
    case mer
    case mfe_MU
    case mfe
    case naq_NA
    case naq
    case ne_IN
    case ne_NP
    case ne
    case nd_ZW
    case nd
    case nb_NO
    case nb
    case nn_NO
    case nn
    case nyn_UG
    case nyn
    case or_IN
    case or
    case om_ET
    case om_KE
    case om
    case ps_AF
    case ps
    case fa_AF
    case fa_IR
    case fa
    case pl_PL
    case pl
    case pt_BR
    case pt_GW
    case pt_MZ
    case pt_PT
    case pt
    case pa_Arab
    case pa_Arab_PK
    case pa_Guru
    case pa_Guru_IN
    case pa
    case ro_MD
    case ro_RO
    case ro
    case rm_CH
    case rm
    case rof_TZ
    case rof
    case ru_MD
    case ru_RU
    case ru_UA
    case ru
    case rwk_TZ
    case rwk
    case saq_KE
    case saq
    case sg_CF
    case sg
    case seh_MZ
    case seh
    case sr_Cyrl
    case sr_Cyrl_BA
    case sr_Cyrl_ME
    case sr_Cyrl_RS
    case sr_Latn
    case sr_Latn_BA
    case sr_Latn_ME
    case sr_Latn_RS
    case sr
    case sn_ZW
    case sn
    case ii_CN
    case ii
    case si_LK
    case si
    case sk_SK
    case sk
    case sl_SI
    case sl
    case xog_UG
    case xog
    case so_DJ
    case so_ET
    case so_KE
    case so_SO
    case so
    case es_AR
    case es_BO
    case es_CL
    case es_CO
    case es_CR
    case es_DO
    case es_EC
    case es_SV
    case es_GQ
    case es_GT
    case es_HN
    case es_419
    case es_MX
    case es_NI
    case es_PA
    case es_PY
    case es_PE
    case es_PR
    case es_ES
    case es_US
    case es_UY
    case es_VE
    case es
    case sw_KE
    case sw_TZ
    case sw
    case sv_FI
    case sv_SE
    case sv
    case gsw_CH
    case gsw
    case shi_Latn
    case shi_Latn_MA
    case shi_Tfng
    case shi_Tfng_MA
    case shi
    case dav_KE
    case dav
    case ta_IN
    case ta_LK
    case ta
    case te_IN
    case te
    case teo_KE
    case teo_UG
    case teo
    case th_TH
    case th
    case bo_CN
    case bo_IN
    case bo
    case ti_ER
    case ti_ET
    case ti
    case to_TO
    case to
    case tr_TR
    case tr
    case uk_UA
    case uk
    case ur_IN
    case ur_PK
    case ur
    case uz_Arab
    case uz_Arab_AF
    case uz_Cyrl
    case uz_Cyrl_UZ
    case uz_Latn
    case uz_Latn_UZ
    case uz
    case vi_VN
    case vi
    case vun_TZ
    case vun
    case cy_GB
    case cy
    case yo_NG
    case yo
    case zu_ZA
    case zu

    public init?(rawValue: String) {
        switch rawValue {
        case "af_NA": self = .af_NA
        case "af_ZA": self = .af_ZA
        case "af": self = .af
        case "ak_GH": self = .ak_GH
        case "ak": self = .ak
        case "sq_AL": self = .sq_AL
        case "sq": self = .sq
        case "am_ET": self = .am_ET
        case "am": self = .am
        case "ar_DZ": self = .ar_DZ
        case "ar_BH": self = .ar_BH
        case "ar_EG": self = .ar_EG
        case "ar_IQ": self = .ar_IQ
        case "ar_JO": self = .ar_JO
        case "ar_KW": self = .ar_KW
        case "ar_LB": self = .ar_LB
        case "ar_LY": self = .ar_LY
        case "ar_MA": self = .ar_MA
        case "ar_OM": self = .ar_OM
        case "ar_QA": self = .ar_QA
        case "ar_SA": self = .ar_SA
        case "ar_SD": self = .ar_SD
        case "ar_SY": self = .ar_SY
        case "ar_TN": self = .ar_TN
        case "ar_AE": self = .ar_AE
        case "ar_YE": self = .ar_YE
        case "ar": self = .ar
        case "hy_AM": self = .hy_AM
        case "hy": self = .hy
        case "as_IN": self = .as_IN
        case "as": self = .as
        case "asa_TZ": self = .asa_TZ
        case "asa": self = .asa
        case "az_Cyrl": self = .az_Cyrl
        case "az_Cyrl_AZ": self = .az_Cyrl_AZ
        case "az_Latn": self = .az_Latn
        case "az_Latn_AZ": self = .az_Latn_AZ
        case "az": self = .az
        case "bm_ML": self = .bm_ML
        case "bm": self = .bm
        case "eu_ES": self = .eu_ES
        case "eu": self = .eu
        case "be_BY": self = .be_BY
        case "be": self = .be
        case "bem_ZM": self = .bem_ZM
        case "bem": self = .bem
        case "bez_TZ": self = .bez_TZ
        case "bez": self = .bez
        case "bn_BD": self = .bn_BD
        case "bn_IN": self = .bn_IN
        case "bn": self = .bn
        case "bs_BA": self = .bs_BA
        case "bs": self = .bs
        case "bg_BG": self = .bg_BG
        case "bg": self = .bg
        case "my_MM": self = .my_MM
        case "my": self = .my
        case "yue_Hant_HK": self = .yue_Hant_HK
        case "ca_ES": self = .ca_ES
        case "ca": self = .ca
        case "tzm_Latn": self = .tzm_Latn
        case "tzm_Latn_MA": self = .tzm_Latn_MA
        case "tzm": self = .tzm
        case "chr_US": self = .chr_US
        case "chr": self = .chr
        case "cgg_UG": self = .cgg_UG
        case "cgg": self = .cgg
        case "zh_Hans": self = .zh_Hans
        case "zh_Hans_CN": self = .zh_Hans_CN
        case "zh_Hans_HK": self = .zh_Hans_HK
        case "zh_Hans_MO": self = .zh_Hans_MO
        case "zh_Hans_SG": self = .zh_Hans_SG
        case "zh-Hant_CN": self = .zh_Hant_CN
        case "zh-HK_CN": self = .zh_HK_CN
        case "zh_Hant_MO": self = .zh_Hant_MO
        case "zh_Hant_TW": self = .zh_Hant_TW
        case "zh_Hant_HK": self = .zh_Hant_HK
        case "zh_Hant": self = .zh_Hant
        case "zh": self = .zh
        case "kw_GB": self = .kw_GB
        case "kw": self = .kw
        case "hr_HR": self = .hr_HR
        case "hr": self = .hr
        case "cs_CZ": self = .cs_CZ
        case "cs": self = .cs
        case "da_DK": self = .da_DK
        case "da": self = .da
        case "nl_BE": self = .nl_BE
        case "nl_NL": self = .nl_NL
        case "nl": self = .nl
        case "ebu_KE": self = .ebu_KE
        case "ebu": self = .ebu
        case "en_AS": self = .en_AS
        case "en_AU": self = .en_AU
        case "en_BE": self = .en_BE
        case "en_BZ": self = .en_BZ
        case "en_BW": self = .en_BW
        case "en_CA": self = .en_CA
        case "en_GU": self = .en_GU
        case "en_HK": self = .en_HK
        case "en_IN": self = .en_IN
        case "en_IE": self = .en_IE
        case "en_IL": self = .en_IL
        case "en_JM": self = .en_JM
        case "en_MT": self = .en_MT
        case "en_MH": self = .en_MH
        case "en_MU": self = .en_MU
        case "en_NA": self = .en_NA
        case "en_NZ": self = .en_NZ
        case "en_MP": self = .en_MP
        case "en_PK": self = .en_PK
        case "en_PH": self = .en_PH
        case "en_SG": self = .en_SG
        case "en_ZA": self = .en_ZA
        case "en_TT": self = .en_TT
        case "en_UM": self = .en_UM
        case "en_VI": self = .en_VI
        case "en_GB": self = .en_GB
        case "en_US": self = .en_US
        case "en_ZW": self = .en_ZW
        case "en_CN": self = .en_CN
        case "en": self = .en
        case "eo": self = .eo
        case "et_EE": self = .et_EE
        case "et": self = .et
        case "ee_GH": self = .ee_GH
        case "ee_TG": self = .ee_TG
        case "ee": self = .ee
        case "fo_FO": self = .fo_FO
        case "fo": self = .fo
        case "fil_PH": self = .fil_PH
        case "fil": self = .fil
        case "fi_FI": self = .fi_FI
        case "fi": self = .fi
        case "fr_BE": self = .fr_BE
        case "fr_BJ": self = .fr_BJ
        case "fr_BF": self = .fr_BF
        case "fr_BI": self = .fr_BI
        case "fr_CM": self = .fr_CM
        case "fr_CA": self = .fr_CA
        case "fr_CF": self = .fr_CF
        case "fr_TD": self = .fr_TD
        case "fr_KM": self = .fr_KM
        case "fr_CG": self = .fr_CG
        case "fr_CD": self = .fr_CD
        case "fr_CI": self = .fr_CI
        case "fr_DJ": self = .fr_DJ
        case "fr_GQ": self = .fr_GQ
        case "fr_FR": self = .fr_FR
        case "fr_GA": self = .fr_GA
        case "fr_GP": self = .fr_GP
        case "fr_GN": self = .fr_GN
        case "fr_LU": self = .fr_LU
        case "fr_MG": self = .fr_MG
        case "fr_ML": self = .fr_ML
        case "fr_MQ": self = .fr_MQ
        case "fr_MC": self = .fr_MC
        case "fr_NE": self = .fr_NE
        case "fr_RW": self = .fr_RW
        case "fr_RE": self = .fr_RE
        case "fr_BL": self = .fr_BL
        case "fr_MF": self = .fr_MF
        case "fr_SN": self = .fr_SN
        case "fr_CH": self = .fr_CH
        case "fr_TG": self = .fr_TG
        case "fr": self = .fr
        case "ff_SN": self = .ff_SN
        case "ff": self = .ff
        case "gl_ES": self = .gl_ES
        case "gl": self = .gl
        case "lg_UG": self = .lg_UG
        case "lg": self = .lg
        case "ka_GE": self = .ka_GE
        case "ka": self = .ka
        case "de_AT": self = .de_AT
        case "de_BE": self = .de_BE
        case "de_DE": self = .de_DE
        case "de_LI": self = .de_LI
        case "de_LU": self = .de_LU
        case "de_CH": self = .de_CH
        case "de": self = .de
        case "el_CY": self = .el_CY
        case "el_GR": self = .el_GR
        case "el": self = .el
        case "gu_IN": self = .gu_IN
        case "gu": self = .gu
        case "guz_KE": self = .guz_KE
        case "guz": self = .guz
        case "ha_Latn": self = .ha_Latn
        case "ha_Latn_GH": self = .ha_Latn_GH
        case "ha_Latn_NE": self = .ha_Latn_NE
        case "ha_Latn_NG": self = .ha_Latn_NG
        case "ha": self = .ha
        case "haw_US": self = .haw_US
        case "haw": self = .haw
        case "he_IL": self = .he_IL
        case "he": self = .he
        case "hi_IN": self = .hi_IN
        case "hi": self = .hi
        case "hu_HU": self = .hu_HU
        case "hu": self = .hu
        case "is_IS": self = .is_IS
        case "is": self = .is
        case "ig_NG": self = .ig_NG
        case "ig": self = .ig
        case "id_ID": self = .id_ID
        case "id": self = .id
        case "ga_IE": self = .ga_IE
        case "ga": self = .ga
        case "it_IT": self = .it_IT
        case "it_CH": self = .it_CH
        case "it": self = .it
        case "ja_JP": self = .ja_JP
        case "ja": self = .ja
        case "kea_CV": self = .kea_CV
        case "kea": self = .kea
        case "kab_DZ": self = .kab_DZ
        case "kab": self = .kab
        case "kl_GL": self = .kl_GL
        case "kl": self = .kl
        case "kln_KE": self = .kln_KE
        case "kln": self = .kln
        case "kam_KE": self = .kam_KE
        case "kam": self = .kam
        case "kn_IN": self = .kn_IN
        case "kn": self = .kn
        case "kk_Cyrl": self = .kk_Cyrl
        case "kk_Cyrl_KZ": self = .kk_Cyrl_KZ
        case "kk": self = .kk
        case "km_KH": self = .km_KH
        case "km": self = .km
        case "ki_KE": self = .ki_KE
        case "ki": self = .ki
        case "rw_RW": self = .rw_RW
        case "rw": self = .rw
        case "kok_IN": self = .kok_IN
        case "kok": self = .kok
        case "ko_KR": self = .ko_KR
        case "ko": self = .ko
        case "khq_ML": self = .khq_ML
        case "khq": self = .khq
        case "ses_ML": self = .ses_ML
        case "ses": self = .ses
        case "lag_TZ": self = .lag_TZ
        case "lag": self = .lag
        case "lv_LV": self = .lv_LV
        case "lv": self = .lv
        case "lt_LT": self = .lt_LT
        case "lt": self = .lt
        case "luo_KE": self = .luo_KE
        case "luo": self = .luo
        case "luy_KE": self = .luy_KE
        case "luy": self = .luy
        case "mk_MK": self = .mk_MK
        case "mk": self = .mk
        case "jmc_TZ": self = .jmc_TZ
        case "jmc": self = .jmc
        case "kde_TZ": self = .kde_TZ
        case "kde": self = .kde
        case "mg_MG": self = .mg_MG
        case "mg": self = .mg
        case "ms_BN": self = .ms_BN
        case "ms_MY": self = .ms_MY
        case "ms": self = .ms
        case "ml_IN": self = .ml_IN
        case "ml": self = .ml
        case "mt_MT": self = .mt_MT
        case "mt": self = .mt
        case "gv_GB": self = .gv_GB
        case "gv": self = .gv
        case "mr_IN": self = .mr_IN
        case "mr": self = .mr
        case "mas_KE": self = .mas_KE
        case "mas_TZ": self = .mas_TZ
        case "mas": self = .mas
        case "mer_KE": self = .mer_KE
        case "mer": self = .mer
        case "mfe_MU": self = .mfe_MU
        case "mfe": self = .mfe
        case "naq_NA": self = .naq_NA
        case "naq": self = .naq
        case "ne_IN": self = .ne_IN
        case "ne_NP": self = .ne_NP
        case "ne": self = .ne
        case "nd_ZW": self = .nd_ZW
        case "nd": self = .nd
        case "nb_NO": self = .nb_NO
        case "nb": self = .nb
        case "nn_NO": self = .nn_NO
        case "nn": self = .nn
        case "nyn_UG": self = .nyn_UG
        case "nyn": self = .nyn
        case "or_IN": self = .or_IN
        case "or": self = .or
        case "om_ET": self = .om_ET
        case "om_KE": self = .om_KE
        case "om": self = .om
        case "ps_AF": self = .ps_AF
        case "ps": self = .ps
        case "fa_AF": self = .fa_AF
        case "fa_IR": self = .fa_IR
        case "fa": self = .fa
        case "pl_PL": self = .pl_PL
        case "pl": self = .pl
        case "pt_BR": self = .pt_BR
        case "pt_GW": self = .pt_GW
        case "pt_MZ": self = .pt_MZ
        case "pt_PT": self = .pt_PT
        case "pt": self = .pt
        case "pa_Arab": self = .pa_Arab
        case "pa_Arab_PK": self = .pa_Arab_PK
        case "pa_Guru": self = .pa_Guru
        case "pa_Guru_IN": self = .pa_Guru_IN
        case "pa": self = .pa
        case "ro_MD": self = .ro_MD
        case "ro_RO": self = .ro_RO
        case "ro": self = .ro
        case "rm_CH": self = .rm_CH
        case "rm": self = .rm
        case "rof_TZ": self = .rof_TZ
        case "rof": self = .rof
        case "ru_MD": self = .ru_MD
        case "ru_RU": self = .ru_RU
        case "ru_UA": self = .ru_UA
        case "ru": self = .ru
        case "rwk_TZ": self = .rwk_TZ
        case "rwk": self = .rwk
        case "saq_KE": self = .saq_KE
        case "saq": self = .saq
        case "sg_CF": self = .sg_CF
        case "sg": self = .sg
        case "seh_MZ": self = .seh_MZ
        case "seh": self = .seh
        case "sr_Cyrl": self = .sr_Cyrl
        case "sr_Cyrl_BA": self = .sr_Cyrl_BA
        case "sr_Cyrl_ME": self = .sr_Cyrl_ME
        case "sr_Cyrl_RS": self = .sr_Cyrl_RS
        case "sr_Latn": self = .sr_Latn
        case "sr_Latn_BA": self = .sr_Latn_BA
        case "sr_Latn_ME": self = .sr_Latn_ME
        case "sr_Latn_RS": self = .sr_Latn_RS
        case "sr": self = .sr
        case "sn_ZW": self = .sn_ZW
        case "sn": self = .sn
        case "ii_CN": self = .ii_CN
        case "ii": self = .ii
        case "si_LK": self = .si_LK
        case "si": self = .si
        case "sk_SK": self = .sk_SK
        case "sk": self = .sk
        case "sl_SI": self = .sl_SI
        case "sl": self = .sl
        case "xog_UG": self = .xog_UG
        case "xog": self = .xog
        case "so_DJ": self = .so_DJ
        case "so_ET": self = .so_ET
        case "so_KE": self = .so_KE
        case "so_SO": self = .so_SO
        case "so": self = .so
        case "es_AR": self = .es_AR
        case "es_BO": self = .es_BO
        case "es_CL": self = .es_CL
        case "es_CO": self = .es_CO
        case "es_CR": self = .es_CR
        case "es_DO": self = .es_DO
        case "es_EC": self = .es_EC
        case "es_SV": self = .es_SV
        case "es_GQ": self = .es_GQ
        case "es_GT": self = .es_GT
        case "es_HN": self = .es_HN
        case "es_419": self = .es_419
        case "es_MX": self = .es_MX
        case "es_NI": self = .es_NI
        case "es_PA": self = .es_PA
        case "es_PY": self = .es_PY
        case "es_PE": self = .es_PE
        case "es_PR": self = .es_PR
        case "es_ES": self = .es_ES
        case "es_US": self = .es_US
        case "es_UY": self = .es_UY
        case "es_VE": self = .es_VE
        case "es": self = .es
        case "sw_KE": self = .sw_KE
        case "sw_TZ": self = .sw_TZ
        case "sw": self = .sw
        case "sv_FI": self = .sv_FI
        case "sv_SE": self = .sv_SE
        case "sv": self = .sv
        case "gsw_CH": self = .gsw_CH
        case "gsw": self = .gsw
        case "shi_Latn": self = .shi_Latn
        case "shi_Latn_MA": self = .shi_Latn_MA
        case "shi_Tfng": self = .shi_Tfng
        case "shi_Tfng_MA": self = .shi_Tfng_MA
        case "shi": self = .shi
        case "dav_KE": self = .dav_KE
        case "dav": self = .dav
        case "ta_IN": self = .ta_IN
        case "ta_LK": self = .ta_LK
        case "ta": self = .ta
        case "te_IN": self = .te_IN
        case "te": self = .te
        case "teo_KE": self = .teo_KE
        case "teo_UG": self = .teo_UG
        case "teo": self = .teo
        case "th_TH": self = .th_TH
        case "th": self = .th
        case "bo_CN": self = .bo_CN
        case "bo_IN": self = .bo_IN
        case "bo": self = .bo
        case "ti_ER": self = .ti_ER
        case "ti_ET": self = .ti_ET
        case "ti": self = .ti
        case "to_TO": self = .to_TO
        case "to": self = .to
        case "tr_TR": self = .tr_TR
        case "tr": self = .tr
        case "uk_UA": self = .uk_UA
        case "uk": self = .uk
        case "ur_IN": self = .ur_IN
        case "ur_PK": self = .ur_PK
        case "ur": self = .ur
        case "uz_Arab": self = .uz_Arab
        case "uz_Arab_AF": self = .uz_Arab_AF
        case "uz_Cyrl": self = .uz_Cyrl
        case "uz_Cyrl_UZ": self = .uz_Cyrl_UZ
        case "uz_Latn": self = .uz_Latn
        case "uz_Latn_UZ": self = .uz_Latn_UZ
        case "uz": self = .uz
        case "vi_VN": self = .vi_VN
        case "vi": self = .vi
        case "vun_TZ": self = .vun_TZ
        case "vun": self = .vun
        case "cy_GB": self = .cy_GB
        case "cy": self = .cy
        case "yo_NG": self = .yo_NG
        case "yo": self = .yo
        case "zu_ZA": self = .zu_ZA
        case "zu": self = .zu
        default: return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .af_NA: return "af_NA"
        case .af_ZA: return "af_ZA"
        case .af: return "af"
        case .ak_GH: return "ak_GH"
        case .ak: return "ak"
        case .sq_AL: return "sq_AL"
        case .sq: return "sq"
        case .am_ET: return "am_ET"
        case .am: return "am"
        case .ar_DZ: return "ar_DZ"
        case .ar_BH: return "ar_BH"
        case .ar_EG: return "ar_EG"
        case .ar_IQ: return "ar_IQ"
        case .ar_JO: return "ar_JO"
        case .ar_KW: return "ar_KW"
        case .ar_LB: return "ar_LB"
        case .ar_LY: return "ar_LY"
        case .ar_MA: return "ar_MA"
        case .ar_OM: return "ar_OM"
        case .ar_QA: return "ar_QA"
        case .ar_SA: return "ar_SA"
        case .ar_SD: return "ar_SD"
        case .ar_SY: return "ar_SY"
        case .ar_TN: return "ar_TN"
        case .ar_AE: return "ar_AE"
        case .ar_YE: return "ar_YE"
        case .ar: return "ar"
        case .hy_AM: return "hy_AM"
        case .hy: return "hy"
        case .as_IN: return "as_IN"
        case .as: return "as"
        case .asa_TZ: return "asa_TZ"
        case .asa: return "asa"
        case .az_Cyrl: return "az_Cyrl"
        case .az_Cyrl_AZ: return "az_Cyrl_AZ"
        case .az_Latn: return "az_Latn"
        case .az_Latn_AZ: return "az_Latn_AZ"
        case .az: return "az"
        case .bm_ML: return "bm_ML"
        case .bm: return "bm"
        case .eu_ES: return "eu_ES"
        case .eu: return "eu"
        case .be_BY: return "be_BY"
        case .be: return "be"
        case .bem_ZM: return "bem_ZM"
        case .bem: return "bem"
        case .bez_TZ: return "bez_TZ"
        case .bez: return "bez"
        case .bn_BD: return "bn_BD"
        case .bn_IN: return "bn_IN"
        case .bn: return "bn"
        case .bs_BA: return "bs_BA"
        case .bs: return "bs"
        case .bg_BG: return "bg_BG"
        case .bg: return "bg"
        case .my_MM: return "my_MM"
        case .my: return "my"
        case .yue_Hant_HK: return "yue_Hant_HK"
        case .ca_ES: return "ca_ES"
        case .ca: return "ca"
        case .tzm_Latn: return "tzm_Latn"
        case .tzm_Latn_MA: return "tzm_Latn_MA"
        case .tzm: return "tzm"
        case .chr_US: return "chr_US"
        case .chr: return "chr"
        case .cgg_UG: return "cgg_UG"
        case .cgg: return "cgg"
        case .zh_Hans: return "zh_Hans"
        case .zh_Hans_CN: return "zh_Hans_CN"
        case .zh_Hans_HK: return "zh_Hans_HK"
        case .zh_Hans_MO: return "zh_Hans_MO"
        case .zh_Hans_SG: return "zh_Hans_SG"
        case .zh_Hant_CN: return "zh-Hant_CN"
        case .zh_HK_CN: return "zh-HK_CN"
        case .zh_Hant_MO: return "zh_Hant_MO"
        case .zh_Hant_TW: return "zh_Hant_TW"
        case .zh_Hant_HK: return "zh_Hant_HK"
        case .zh_Hant: return "zh_Hant"
        case .zh: return "zh"
        case .kw_GB: return "kw_GB"
        case .kw: return "kw"
        case .hr_HR: return "hr_HR"
        case .hr: return "hr"
        case .cs_CZ: return "cs_CZ"
        case .cs: return "cs"
        case .da_DK: return "da_DK"
        case .da: return "da"
        case .nl_BE: return "nl_BE"
        case .nl_NL: return "nl_NL"
        case .nl: return "nl"
        case .ebu_KE: return "ebu_KE"
        case .ebu: return "ebu"
        case .en_AS: return "en_AS"
        case .en_AU: return "en_AU"
        case .en_BE: return "en_BE"
        case .en_BZ: return "en_BZ"
        case .en_BW: return "en_BW"
        case .en_CA: return "en_CA"
        case .en_GU: return "en_GU"
        case .en_HK: return "en_HK"
        case .en_IN: return "en_IN"
        case .en_IE: return "en_IE"
        case .en_IL: return "en_IL"
        case .en_JM: return "en_JM"
        case .en_MT: return "en_MT"
        case .en_MH: return "en_MH"
        case .en_MU: return "en_MU"
        case .en_NA: return "en_NA"
        case .en_NZ: return "en_NZ"
        case .en_MP: return "en_MP"
        case .en_PK: return "en_PK"
        case .en_PH: return "en_PH"
        case .en_SG: return "en_SG"
        case .en_ZA: return "en_ZA"
        case .en_TT: return "en_TT"
        case .en_UM: return "en_UM"
        case .en_VI: return "en_VI"
        case .en_GB: return "en_GB"
        case .en_US: return "en_US"
        case .en_ZW: return "en_ZW"
        case .en_CN: return "en_CN"
        case .en: return "en"
        case .eo: return "eo"
        case .et_EE: return "et_EE"
        case .et: return "et"
        case .ee_GH: return "ee_GH"
        case .ee_TG: return "ee_TG"
        case .ee: return "ee"
        case .fo_FO: return "fo_FO"
        case .fo: return "fo"
        case .fil_PH: return "fil_PH"
        case .fil: return "fil"
        case .fi_FI: return "fi_FI"
        case .fi: return "fi"
        case .fr_BE: return "fr_BE"
        case .fr_BJ: return "fr_BJ"
        case .fr_BF: return "fr_BF"
        case .fr_BI: return "fr_BI"
        case .fr_CM: return "fr_CM"
        case .fr_CA: return "fr_CA"
        case .fr_CF: return "fr_CF"
        case .fr_TD: return "fr_TD"
        case .fr_KM: return "fr_KM"
        case .fr_CG: return "fr_CG"
        case .fr_CD: return "fr_CD"
        case .fr_CI: return "fr_CI"
        case .fr_DJ: return "fr_DJ"
        case .fr_GQ: return "fr_GQ"
        case .fr_FR: return "fr_FR"
        case .fr_GA: return "fr_GA"
        case .fr_GP: return "fr_GP"
        case .fr_GN: return "fr_GN"
        case .fr_LU: return "fr_LU"
        case .fr_MG: return "fr_MG"
        case .fr_ML: return "fr_ML"
        case .fr_MQ: return "fr_MQ"
        case .fr_MC: return "fr_MC"
        case .fr_NE: return "fr_NE"
        case .fr_RW: return "fr_RW"
        case .fr_RE: return "fr_RE"
        case .fr_BL: return "fr_BL"
        case .fr_MF: return "fr_MF"
        case .fr_SN: return "fr_SN"
        case .fr_CH: return "fr_CH"
        case .fr_TG: return "fr_TG"
        case .fr: return "fr"
        case .ff_SN: return "ff_SN"
        case .ff: return "ff"
        case .gl_ES: return "gl_ES"
        case .gl: return "gl"
        case .lg_UG: return "lg_UG"
        case .lg: return "lg"
        case .ka_GE: return "ka_GE"
        case .ka: return "ka"
        case .de_AT: return "de_AT"
        case .de_BE: return "de_BE"
        case .de_DE: return "de_DE"
        case .de_LI: return "de_LI"
        case .de_LU: return "de_LU"
        case .de_CH: return "de_CH"
        case .de: return "de"
        case .el_CY: return "el_CY"
        case .el_GR: return "el_GR"
        case .el: return "el"
        case .gu_IN: return "gu_IN"
        case .gu: return "gu"
        case .guz_KE: return "guz_KE"
        case .guz: return "guz"
        case .ha_Latn: return "ha_Latn"
        case .ha_Latn_GH: return "ha_Latn_GH"
        case .ha_Latn_NE: return "ha_Latn_NE"
        case .ha_Latn_NG: return "ha_Latn_NG"
        case .ha: return "ha"
        case .haw_US: return "haw_US"
        case .haw: return "haw"
        case .he_IL: return "he_IL"
        case .he: return "he"
        case .hi_IN: return "hi_IN"
        case .hi: return "hi"
        case .hu_HU: return "hu_HU"
        case .hu: return "hu"
        case .is_IS: return "is_IS"
        case .is: return "is"
        case .ig_NG: return "ig_NG"
        case .ig: return "ig"
        case .id_ID: return "id_ID"
        case .id: return "id"
        case .ga_IE: return "ga_IE"
        case .ga: return "ga"
        case .it_IT: return "it_IT"
        case .it_CH: return "it_CH"
        case .it: return "it"
        case .ja_JP: return "ja_JP"
        case .ja: return "ja"
        case .kea_CV: return "kea_CV"
        case .kea: return "kea"
        case .kab_DZ: return "kab_DZ"
        case .kab: return "kab"
        case .kl_GL: return "kl_GL"
        case .kl: return "kl"
        case .kln_KE: return "kln_KE"
        case .kln: return "kln"
        case .kam_KE: return "kam_KE"
        case .kam: return "kam"
        case .kn_IN: return "kn_IN"
        case .kn: return "kn"
        case .kk_Cyrl: return "kk_Cyrl"
        case .kk_Cyrl_KZ: return "kk_Cyrl_KZ"
        case .kk: return "kk"
        case .km_KH: return "km_KH"
        case .km: return "km"
        case .ki_KE: return "ki_KE"
        case .ki: return "ki"
        case .rw_RW: return "rw_RW"
        case .rw: return "rw"
        case .kok_IN: return "kok_IN"
        case .kok: return "kok"
        case .ko_KR: return "ko_KR"
        case .ko: return "ko"
        case .khq_ML: return "khq_ML"
        case .khq: return "khq"
        case .ses_ML: return "ses_ML"
        case .ses: return "ses"
        case .lag_TZ: return "lag_TZ"
        case .lag: return "lag"
        case .lv_LV: return "lv_LV"
        case .lv: return "lv"
        case .lt_LT: return "lt_LT"
        case .lt: return "lt"
        case .luo_KE: return "luo_KE"
        case .luo: return "luo"
        case .luy_KE: return "luy_KE"
        case .luy: return "luy"
        case .mk_MK: return "mk_MK"
        case .mk: return "mk"
        case .jmc_TZ: return "jmc_TZ"
        case .jmc: return "jmc"
        case .kde_TZ: return "kde_TZ"
        case .kde: return "kde"
        case .mg_MG: return "mg_MG"
        case .mg: return "mg"
        case .ms_BN: return "ms_BN"
        case .ms_MY: return "ms_MY"
        case .ms: return "ms"
        case .ml_IN: return "ml_IN"
        case .ml: return "ml"
        case .mt_MT: return "mt_MT"
        case .mt: return "mt"
        case .gv_GB: return "gv_GB"
        case .gv: return "gv"
        case .mr_IN: return "mr_IN"
        case .mr: return "mr"
        case .mas_KE: return "mas_KE"
        case .mas_TZ: return "mas_TZ"
        case .mas: return "mas"
        case .mer_KE: return "mer_KE"
        case .mer: return "mer"
        case .mfe_MU: return "mfe_MU"
        case .mfe: return "mfe"
        case .naq_NA: return "naq_NA"
        case .naq: return "naq"
        case .ne_IN: return "ne_IN"
        case .ne_NP: return "ne_NP"
        case .ne: return "ne"
        case .nd_ZW: return "nd_ZW"
        case .nd: return "nd"
        case .nb_NO: return "nb_NO"
        case .nb: return "nb"
        case .nn_NO: return "nn_NO"
        case .nn: return "nn"
        case .nyn_UG: return "nyn_UG"
        case .nyn: return "nyn"
        case .or_IN: return "or_IN"
        case .or: return "or"
        case .om_ET: return "om_ET"
        case .om_KE: return "om_KE"
        case .om: return "om"
        case .ps_AF: return "ps_AF"
        case .ps: return "ps"
        case .fa_AF: return "fa_AF"
        case .fa_IR: return "fa_IR"
        case .fa: return "fa"
        case .pl_PL: return "pl_PL"
        case .pl: return "pl"
        case .pt_BR: return "pt_BR"
        case .pt_GW: return "pt_GW"
        case .pt_MZ: return "pt_MZ"
        case .pt_PT: return "pt_PT"
        case .pt: return "pt"
        case .pa_Arab: return "pa_Arab"
        case .pa_Arab_PK: return "pa_Arab_PK"
        case .pa_Guru: return "pa_Guru"
        case .pa_Guru_IN: return "pa_Guru_IN"
        case .pa: return "pa"
        case .ro_MD: return "ro_MD"
        case .ro_RO: return "ro_RO"
        case .ro: return "ro"
        case .rm_CH: return "rm_CH"
        case .rm: return "rm"
        case .rof_TZ: return "rof_TZ"
        case .rof: return "rof"
        case .ru_MD: return "ru_MD"
        case .ru_RU: return "ru_RU"
        case .ru_UA: return "ru_UA"
        case .ru: return "ru"
        case .rwk_TZ: return "rwk_TZ"
        case .rwk: return "rwk"
        case .saq_KE: return "saq_KE"
        case .saq: return "saq"
        case .sg_CF: return "sg_CF"
        case .sg: return "sg"
        case .seh_MZ: return "seh_MZ"
        case .seh: return "seh"
        case .sr_Cyrl: return "sr_Cyrl"
        case .sr_Cyrl_BA: return "sr_Cyrl_BA"
        case .sr_Cyrl_ME: return "sr_Cyrl_ME"
        case .sr_Cyrl_RS: return "sr_Cyrl_RS"
        case .sr_Latn: return "sr_Latn"
        case .sr_Latn_BA: return "sr_Latn_BA"
        case .sr_Latn_ME: return "sr_Latn_ME"
        case .sr_Latn_RS: return "sr_Latn_RS"
        case .sr: return "sr"
        case .sn_ZW: return "sn_ZW"
        case .sn: return "sn"
        case .ii_CN: return "ii_CN"
        case .ii: return "ii"
        case .si_LK: return "si_LK"
        case .si: return "si"
        case .sk_SK: return "sk_SK"
        case .sk: return "sk"
        case .sl_SI: return "sl_SI"
        case .sl: return "sl"
        case .xog_UG: return "xog_UG"
        case .xog: return "xog"
        case .so_DJ: return "so_DJ"
        case .so_ET: return "so_ET"
        case .so_KE: return "so_KE"
        case .so_SO: return "so_SO"
        case .so: return "so"
        case .es_AR: return "es_AR"
        case .es_BO: return "es_BO"
        case .es_CL: return "es_CL"
        case .es_CO: return "es_CO"
        case .es_CR: return "es_CR"
        case .es_DO: return "es_DO"
        case .es_EC: return "es_EC"
        case .es_SV: return "es_SV"
        case .es_GQ: return "es_GQ"
        case .es_GT: return "es_GT"
        case .es_HN: return "es_HN"
        case .es_419: return "es_419"
        case .es_MX: return "es_MX"
        case .es_NI: return "es_NI"
        case .es_PA: return "es_PA"
        case .es_PY: return "es_PY"
        case .es_PE: return "es_PE"
        case .es_PR: return "es_PR"
        case .es_ES: return "es_ES"
        case .es_US: return "es_US"
        case .es_UY: return "es_UY"
        case .es_VE: return "es_VE"
        case .es: return "es"
        case .sw_KE: return "sw_KE"
        case .sw_TZ: return "sw_TZ"
        case .sw: return "sw"
        case .sv_FI: return "sv_FI"
        case .sv_SE: return "sv_SE"
        case .sv: return "sv"
        case .gsw_CH: return "gsw_CH"
        case .gsw: return "gsw"
        case .shi_Latn: return "shi_Latn"
        case .shi_Latn_MA: return "shi_Latn_MA"
        case .shi_Tfng: return "shi_Tfng"
        case .shi_Tfng_MA: return "shi_Tfng_MA"
        case .shi: return "shi"
        case .dav_KE: return "dav_KE"
        case .dav: return "dav"
        case .ta_IN: return "ta_IN"
        case .ta_LK: return "ta_LK"
        case .ta: return "ta"
        case .te_IN: return "te_IN"
        case .te: return "te"
        case .teo_KE: return "teo_KE"
        case .teo_UG: return "teo_UG"
        case .teo: return "teo"
        case .th_TH: return "th_TH"
        case .th: return "th"
        case .bo_CN: return "bo_CN"
        case .bo_IN: return "bo_IN"
        case .bo: return "bo"
        case .ti_ER: return "ti_ER"
        case .ti_ET: return "ti_ET"
        case .ti: return "ti"
        case .to_TO: return "to_TO"
        case .to: return "to"
        case .tr_TR: return "tr_TR"
        case .tr: return "tr"
        case .uk_UA: return "uk_UA"
        case .uk: return "uk"
        case .ur_IN: return "ur_IN"
        case .ur_PK: return "ur_PK"
        case .ur: return "ur"
        case .uz_Arab: return "uz_Arab"
        case .uz_Arab_AF: return "uz_Arab_AF"
        case .uz_Cyrl: return "uz_Cyrl"
        case .uz_Cyrl_UZ: return "uz_Cyrl_UZ"
        case .uz_Latn: return "uz_Latn"
        case .uz_Latn_UZ: return "uz_Latn_UZ"
        case .uz: return "uz"
        case .vi_VN: return "vi_VN"
        case .vi: return "vi"
        case .vun_TZ: return "vun_TZ"
        case .vun: return "vun"
        case .cy_GB: return "cy_GB"
        case .cy: return "cy"
        case .yo_NG: return "yo_NG"
        case .yo: return "yo"
        case .zu_ZA: return "zu_ZA"
        case .zu: return "zu"
        }
    }
    
    public var prefix: String {
        return rawValue.components(separatedBy: "_").first ?? rawValue
    }

    public var description: String {
        switch self {
        case .af_NA: return "Afrikaans (Namibia)"
        case .af_ZA: return "Afrikaans (South Africa)"
        case .af: return "Afrikaans"
        case .ak_GH: return "Akan (Ghana)"
        case .ak: return "Akan"
        case .sq_AL: return "Albanian (Albania)"
        case .sq: return "Albanian"
        case .am_ET: return "Amharic (Ethiopia)"
        case .am: return "Amharic"
        case .ar_DZ: return "Arabic (Algeria)"
        case .ar_BH: return "Arabic (Bahrain)"
        case .ar_EG: return "Arabic (Egypt)"
        case .ar_IQ: return "Arabic (Iraq)"
        case .ar_JO: return "Arabic (Jordan)"
        case .ar_KW: return "Arabic (Kuwait)"
        case .ar_LB: return "Arabic (Lebanon)"
        case .ar_LY: return "Arabic (Libya)"
        case .ar_MA: return "Arabic (Morocco)"
        case .ar_OM: return "Arabic (Oman)"
        case .ar_QA: return "Arabic (Qatar)"
        case .ar_SA: return "Arabic (Saudi Arabia)"
        case .ar_SD: return "Arabic (Sudan)"
        case .ar_SY: return "Arabic (Syria)"
        case .ar_TN: return "Arabic (Tunisia)"
        case .ar_AE: return "Arabic (United Arab Emirates)"
        case .ar_YE: return "Arabic (Yemen)"
        case .ar: return "Arabic"
        case .hy_AM: return "Armenian (Armenia)"
        case .hy: return "Armenian"
        case .as_IN: return "Assamese (India)"
        case .as: return "Assamese"
        case .asa_TZ: return "Asu (Tanzania)"
        case .asa: return "Asu"
        case .az_Cyrl: return "Azerbaijani (Cyrillic)"
        case .az_Cyrl_AZ: return "Azerbaijani (Cyrillic, Azerbaijan)"
        case .az_Latn: return "Azerbaijani (Latin)"
        case .az_Latn_AZ: return "Azerbaijani (Latin, Azerbaijan)"
        case .az: return "Azerbaijani"
        case .bm_ML: return "Bambara (Mali)"
        case .bm: return "Bambara"
        case .eu_ES: return "Basque (Spain)"
        case .eu: return "Basque"
        case .be_BY: return "Belarusian (Belarus)"
        case .be: return "Belarusian"
        case .bem_ZM: return "Bemba (Zambia)"
        case .bem: return "Bemba"
        case .bez_TZ: return "Bena (Tanzania)"
        case .bez: return "Bena"
        case .bn_BD: return "Bengali (Bangladesh)"
        case .bn_IN: return "Bengali (India)"
        case .bn: return "Bengali"
        case .bs_BA: return "Bosnian (Bosnia and Herzegovina)"
        case .bs: return "Bosnian"
        case .bg_BG: return "Bulgarian (Bulgaria)"
        case .bg: return "Bulgarian"
        case .my_MM: return "Burmese (Myanmar [Burma])"
        case .my: return "Burmese"
        case .yue_Hant_HK: return "Cantonese (Traditional, Hong Kong SAR China)"
        case .ca_ES: return "Catalan (Spain)"
        case .ca: return "Catalan"
        case .tzm_Latn: return "Central Morocco Tamazight (Latin)"
        case .tzm_Latn_MA: return "Central Morocco Tamazight (Latin, Morocco)"
        case .tzm: return "Central Morocco Tamazight"
        case .chr_US: return "Cherokee (United States)"
        case .chr: return "Cherokee"
        case .cgg_UG: return "Chiga (Uganda)"
        case .cgg: return "Chiga"
        case .zh_Hans: return "Chinese (Simplified Han)"
        case .zh_Hans_CN: return "Chinese (Simplified Han, China)"
        case .zh_Hans_HK: return "Chinese (Simplified Han, Hong Kong SAR China)"
        case .zh_Hans_MO: return "Chinese (Simplified Han, Macau SAR China)"
        case .zh_Hans_SG: return "Chinese (Simplified Han, Singapore)"
        case .zh_Hant, .zh_Hant_CN: return "Chinese (Traditional Han)"
        case .zh_Hant_HK, .zh_HK_CN: return "Chinese (Traditional Han, Hong Kong SAR China)"
        case .zh_Hant_MO: return "Chinese (Traditional Han, Macau SAR China)"
        case .zh_Hant_TW: return "Chinese (Traditional Han, Taiwan)"
        case .zh: return "Chinese"
        case .kw_GB: return "Cornish (United Kingdom)"
        case .kw: return "Cornish"
        case .hr_HR: return "Croatian (Croatia)"
        case .hr: return "Croatian"
        case .cs_CZ: return "Czech (Czech Republic)"
        case .cs: return "Czech"
        case .da_DK: return "Danish (Denmark)"
        case .da: return "Danish"
        case .nl_BE: return "Dutch (Belgium)"
        case .nl_NL: return "Dutch (Netherlands)"
        case .nl: return "Dutch"
        case .ebu_KE: return "Embu (Kenya)"
        case .ebu: return "Embu"
        case .en_AS: return "English (American Samoa)"
        case .en_AU: return "English (Australia)"
        case .en_BE: return "English (Belgium)"
        case .en_BZ: return "English (Belize)"
        case .en_BW: return "English (Botswana)"
        case .en_CA: return "English (Canada)"
        case .en_GU: return "English (Guam)"
        case .en_HK: return "English (Hong Kong SAR China)"
        case .en_IN: return "English (India)"
        case .en_IE: return "English (Ireland)"
        case .en_IL: return "English (Israel)"
        case .en_JM: return "English (Jamaica)"
        case .en_MT: return "English (Malta)"
        case .en_MH: return "English (Marshall Islands)"
        case .en_MU: return "English (Mauritius)"
        case .en_NA: return "English (Namibia)"
        case .en_NZ: return "English (New Zealand)"
        case .en_MP: return "English (Northern Mariana Islands)"
        case .en_PK: return "English (Pakistan)"
        case .en_PH: return "English (Philippines)"
        case .en_SG: return "English (Singapore)"
        case .en_ZA: return "English (South Africa)"
        case .en_TT: return "English (Trinidad and Tobago)"
        case .en_UM: return "English (U.S. Minor Outlying Islands)"
        case .en_VI: return "English (U.S. Virgin Islands)"
        case .en_GB: return "English (United Kingdom)"
        case .en_US: return "English (United States)"
        case .en_ZW: return "English (Zimbabwe)"
        case .en_CN: return "English (China)"
        case .en: return "English"
        case .eo: return "Esperanto"
        case .et_EE: return "Estonian (Estonia)"
        case .et: return "Estonian"
        case .ee_GH: return "Ewe (Ghana)"
        case .ee_TG: return "Ewe (Togo)"
        case .ee: return "Ewe"
        case .fo_FO: return "Faroese (Faroe Islands)"
        case .fo: return "Faroese"
        case .fil_PH: return "Filipino (Philippines)"
        case .fil: return "Filipino"
        case .fi_FI: return "Finnish (Finland)"
        case .fi: return "Finnish"
        case .fr_BE: return "French (Belgium)"
        case .fr_BJ: return "French (Benin)"
        case .fr_BF: return "French (Burkina Faso)"
        case .fr_BI: return "French (Burundi)"
        case .fr_CM: return "French (Cameroon)"
        case .fr_CA: return "French (Canada)"
        case .fr_CF: return "French (Central African Republic)"
        case .fr_TD: return "French (Chad)"
        case .fr_KM: return "French (Comoros)"
        case .fr_CG: return "French (Congo - Brazzaville)"
        case .fr_CD: return "French (Congo - Kinshasa)"
        case .fr_CI: return "French (Côte d’Ivoire)"
        case .fr_DJ: return "French (Djibouti)"
        case .fr_GQ: return "French (Equatorial Guinea)"
        case .fr_FR: return "French (France)"
        case .fr_GA: return "French (Gabon)"
        case .fr_GP: return "French (Guadeloupe)"
        case .fr_GN: return "French (Guinea)"
        case .fr_LU: return "French (Luxembourg)"
        case .fr_MG: return "French (Madagascar)"
        case .fr_ML: return "French (Mali)"
        case .fr_MQ: return "French (Martinique)"
        case .fr_MC: return "French (Monaco)"
        case .fr_NE: return "French (Niger)"
        case .fr_RW: return "French (Rwanda)"
        case .fr_RE: return "French (Réunion)"
        case .fr_BL: return "French (Saint Barthélemy)"
        case .fr_MF: return "French (Saint Martin)"
        case .fr_SN: return "French (Senegal)"
        case .fr_CH: return "French (Switzerland)"
        case .fr_TG: return "French (Togo)"
        case .fr: return "French"
        case .ff_SN: return "Fulah (Senegal)"
        case .ff: return "Fulah"
        case .gl_ES: return "Galician (Spain)"
        case .gl: return "Galician"
        case .lg_UG: return "Ganda (Uganda)"
        case .lg: return "Ganda"
        case .ka_GE: return "Georgian (Georgia)"
        case .ka: return "Georgian"
        case .de_AT: return "German (Austria)"
        case .de_BE: return "German (Belgium)"
        case .de_DE: return "German (Germany)"
        case .de_LI: return "German (Liechtenstein)"
        case .de_LU: return "German (Luxembourg)"
        case .de_CH: return "German (Switzerland)"
        case .de: return "German"
        case .el_CY: return "Greek (Cyprus)"
        case .el_GR: return "Greek (Greece)"
        case .el: return "Greek"
        case .gu_IN: return "Gujarati (India)"
        case .gu: return "Gujarati"
        case .guz_KE: return "Gusii (Kenya)"
        case .guz: return "Gusii"
        case .ha_Latn: return "Hausa (Latin)"
        case .ha_Latn_GH: return "Hausa (Latin, Ghana)"
        case .ha_Latn_NE: return "Hausa (Latin, Niger)"
        case .ha_Latn_NG: return "Hausa (Latin, Nigeria)"
        case .ha: return "Hausa"
        case .haw_US: return "Hawaiian (United States)"
        case .haw: return "Hawaiian"
        case .he_IL: return "Hebrew (Israel)"
        case .he: return "Hebrew"
        case .hi_IN: return "Hindi (India)"
        case .hi: return "Hindi"
        case .hu_HU: return "Hungarian (Hungary)"
        case .hu: return "Hungarian"
        case .is_IS: return "Icelandic (Iceland)"
        case .is: return "Icelandic"
        case .ig_NG: return "Igbo (Nigeria)"
        case .ig: return "Igbo"
        case .id_ID: return "Indonesian (Indonesia)"
        case .id: return "Indonesian"
        case .ga_IE: return "Irish (Ireland)"
        case .ga: return "Irish"
        case .it_IT: return "Italian (Italy)"
        case .it_CH: return "Italian (Switzerland)"
        case .it: return "Italian"
        case .ja_JP: return "Japanese (Japan)"
        case .ja: return "Japanese"
        case .kea_CV: return "Kabuverdianu (Cape Verde)"
        case .kea: return "Kabuverdianu"
        case .kab_DZ: return "Kabyle (Algeria)"
        case .kab: return "Kabyle"
        case .kl_GL: return "Kalaallisut (Greenland)"
        case .kl: return "Kalaallisut"
        case .kln_KE: return "Kalenjin (Kenya)"
        case .kln: return "Kalenjin"
        case .kam_KE: return "Kamba (Kenya)"
        case .kam: return "Kamba"
        case .kn_IN: return "Kannada (India)"
        case .kn: return "Kannada"
        case .kk_Cyrl: return "Kazakh (Cyrillic)"
        case .kk_Cyrl_KZ: return "Kazakh (Cyrillic, Kazakhstan)"
        case .kk: return "Kazakh"
        case .km_KH: return "Khmer (Cambodia)"
        case .km: return "Khmer"
        case .ki_KE: return "Kikuyu (Kenya)"
        case .ki: return "Kikuyu"
        case .rw_RW: return "Kinyarwanda (Rwanda)"
        case .rw: return "Kinyarwanda"
        case .kok_IN: return "Konkani (India)"
        case .kok: return "Konkani"
        case .ko_KR: return "Korean (South Korea)"
        case .ko: return "Korean"
        case .khq_ML: return "Koyra Chiini (Mali)"
        case .khq: return "Koyra Chiini"
        case .ses_ML: return "Koyraboro Senni (Mali)"
        case .ses: return "Koyraboro Senni"
        case .lag_TZ: return "Langi (Tanzania)"
        case .lag: return "Langi"
        case .lv_LV: return "Latvian (Latvia)"
        case .lv: return "Latvian"
        case .lt_LT: return "Lithuanian (Lithuania)"
        case .lt: return "Lithuanian"
        case .luo_KE: return "Luo (Kenya)"
        case .luo: return "Luo"
        case .luy_KE: return "Luyia (Kenya)"
        case .luy: return "Luyia"
        case .mk_MK: return "Macedonian (Macedonia)"
        case .mk: return "Macedonian"
        case .jmc_TZ: return "Machame (Tanzania)"
        case .jmc: return "Machame"
        case .kde_TZ: return "Makonde (Tanzania)"
        case .kde: return "Makonde"
        case .mg_MG: return "Malagasy (Madagascar)"
        case .mg: return "Malagasy"
        case .ms_BN: return "Malay (Brunei)"
        case .ms_MY: return "Malay (Malaysia)"
        case .ms: return "Malay"
        case .ml_IN: return "Malayalam (India)"
        case .ml: return "Malayalam"
        case .mt_MT: return "Maltese (Malta)"
        case .mt: return "Maltese"
        case .gv_GB: return "Manx (United Kingdom)"
        case .gv: return "Manx"
        case .mr_IN: return "Marathi (India)"
        case .mr: return "Marathi"
        case .mas_KE: return "Masai (Kenya)"
        case .mas_TZ: return "Masai (Tanzania)"
        case .mas: return "Masai"
        case .mer_KE: return "Meru (Kenya)"
        case .mer: return "Meru"
        case .mfe_MU: return "Morisyen (Mauritius)"
        case .mfe: return "Morisyen"
        case .naq_NA: return "Nama (Namibia)"
        case .naq: return "Nama"
        case .ne_IN: return "Nepali (India)"
        case .ne_NP: return "Nepali (Nepal)"
        case .ne: return "Nepali"
        case .nd_ZW: return "North Ndebele (Zimbabwe)"
        case .nd: return "North Ndebele"
        case .nb_NO: return "Norwegian Bokmål (Norway)"
        case .nb: return "Norwegian Bokmål"
        case .nn_NO: return "Norwegian Nynorsk (Norway)"
        case .nn: return "Norwegian Nynorsk"
        case .nyn_UG: return "Nyankole (Uganda)"
        case .nyn: return "Nyankole"
        case .or_IN: return "Oriya (India)"
        case .or: return "Oriya"
        case .om_ET: return "Oromo (Ethiopia)"
        case .om_KE: return "Oromo (Kenya)"
        case .om: return "Oromo"
        case .ps_AF: return "Pashto (Afghanistan)"
        case .ps: return "Pashto"
        case .fa_AF: return "Persian (Afghanistan)"
        case .fa_IR: return "Persian (Iran)"
        case .fa: return "Persian"
        case .pl_PL: return "Polish (Poland)"
        case .pl: return "Polish"
        case .pt_BR: return "Portuguese (Brazil)"
        case .pt_GW: return "Portuguese (Guinea-Bissau)"
        case .pt_MZ: return "Portuguese (Mozambique)"
        case .pt_PT: return "Portuguese (Portugal)"
        case .pt: return "Portuguese"
        case .pa_Arab: return "Punjabi (Arabic)"
        case .pa_Arab_PK: return "Punjabi (Arabic, Pakistan)"
        case .pa_Guru: return "Punjabi (Gurmukhi)"
        case .pa_Guru_IN: return "Punjabi (Gurmukhi, India)"
        case .pa: return "Punjabi"
        case .ro_MD: return "Romanian (Moldova)"
        case .ro_RO: return "Romanian (Romania)"
        case .ro: return "Romanian"
        case .rm_CH: return "Romansh (Switzerland)"
        case .rm: return "Romansh"
        case .rof_TZ: return "Rombo (Tanzania)"
        case .rof: return "Rombo"
        case .ru_MD: return "Russian (Moldova)"
        case .ru_RU: return "Russian (Russia)"
        case .ru_UA: return "Russian (Ukraine)"
        case .ru: return "Russian"
        case .rwk_TZ: return "Rwa (Tanzania)"
        case .rwk: return "Rwa"
        case .saq_KE: return "Samburu (Kenya)"
        case .saq: return "Samburu"
        case .sg_CF: return "Sango (Central African Republic)"
        case .sg: return "Sango"
        case .seh_MZ: return "Sena (Mozambique)"
        case .seh: return "Sena"
        case .sr_Cyrl: return "Serbian (Cyrillic)"
        case .sr_Cyrl_BA: return "Serbian (Cyrillic, Bosnia and Herzegovina)"
        case .sr_Cyrl_ME: return "Serbian (Cyrillic, Montenegro)"
        case .sr_Cyrl_RS: return "Serbian (Cyrillic, Serbia)"
        case .sr_Latn: return "Serbian (Latin)"
        case .sr_Latn_BA: return "Serbian (Latin, Bosnia and Herzegovina)"
        case .sr_Latn_ME: return "Serbian (Latin, Montenegro)"
        case .sr_Latn_RS: return "Serbian (Latin, Serbia)"
        case .sr: return "Serbian"
        case .sn_ZW: return "Shona (Zimbabwe)"
        case .sn: return "Shona"
        case .ii_CN: return "Sichuan Yi (China)"
        case .ii: return "Sichuan Yi"
        case .si_LK: return "Sinhala (Sri Lanka)"
        case .si: return "Sinhala"
        case .sk_SK: return "Slovak (Slovakia)"
        case .sk: return "Slovak"
        case .sl_SI: return "Slovenian (Slovenia)"
        case .sl: return "Slovenian"
        case .xog_UG: return "Soga (Uganda)"
        case .xog: return "Soga"
        case .so_DJ: return "Somali (Djibouti)"
        case .so_ET: return "Somali (Ethiopia)"
        case .so_KE: return "Somali (Kenya)"
        case .so_SO: return "Somali (Somalia)"
        case .so: return "Somali"
        case .es_AR: return "Spanish (Argentina)"
        case .es_BO: return "Spanish (Bolivia)"
        case .es_CL: return "Spanish (Chile)"
        case .es_CO: return "Spanish (Colombia)"
        case .es_CR: return "Spanish (Costa Rica)"
        case .es_DO: return "Spanish (Dominican Republic)"
        case .es_EC: return "Spanish (Ecuador)"
        case .es_SV: return "Spanish (El Salvador)"
        case .es_GQ: return "Spanish (Equatorial Guinea)"
        case .es_GT: return "Spanish (Guatemala)"
        case .es_HN: return "Spanish (Honduras)"
        case .es_419: return "Spanish (Latin America)"
        case .es_MX: return "Spanish (Mexico)"
        case .es_NI: return "Spanish (Nicaragua)"
        case .es_PA: return "Spanish (Panama)"
        case .es_PY: return "Spanish (Paraguay)"
        case .es_PE: return "Spanish (Peru)"
        case .es_PR: return "Spanish (Puerto Rico)"
        case .es_ES: return "Spanish (Spain)"
        case .es_US: return "Spanish (United States)"
        case .es_UY: return "Spanish (Uruguay)"
        case .es_VE: return "Spanish (Venezuela)"
        case .es: return "Spanish"
        case .sw_KE: return "Swahili (Kenya)"
        case .sw_TZ: return "Swahili (Tanzania)"
        case .sw: return "Swahili"
        case .sv_FI: return "Swedish (Finland)"
        case .sv_SE: return "Swedish (Sweden)"
        case .sv: return "Swedish"
        case .gsw_CH: return "Swiss German (Switzerland)"
        case .gsw: return "Swiss German"
        case .shi_Latn: return "Tachelhit (Latin)"
        case .shi_Latn_MA: return "Tachelhit (Latin, Morocco)"
        case .shi_Tfng: return "Tachelhit (Tifinagh)"
        case .shi_Tfng_MA: return "Tachelhit (Tifinagh, Morocco)"
        case .shi: return "Tachelhit"
        case .dav_KE: return "Taita (Kenya)"
        case .dav: return "Taita"
        case .ta_IN: return "Tamil (India)"
        case .ta_LK: return "Tamil (Sri Lanka)"
        case .ta: return "Tamil"
        case .te_IN: return "Telugu (India)"
        case .te: return "Telugu"
        case .teo_KE: return "Teso (Kenya)"
        case .teo_UG: return "Teso (Uganda)"
        case .teo: return "Teso"
        case .th_TH: return "Thai (Thailand)"
        case .th: return "Thai"
        case .bo_CN: return "Tibetan (China)"
        case .bo_IN: return "Tibetan (India)"
        case .bo: return "Tibetan"
        case .ti_ER: return "Tigrinya (Eritrea)"
        case .ti_ET: return "Tigrinya (Ethiopia)"
        case .ti: return "Tigrinya"
        case .to_TO: return "Tonga (Tonga)"
        case .to: return "Tonga"
        case .tr_TR: return "Turkish (Turkey)"
        case .tr: return "Turkish"
        case .uk_UA: return "Ukrainian (Ukraine)"
        case .uk: return "Ukrainian"
        case .ur_IN: return "Urdu (India)"
        case .ur_PK: return "Urdu (Pakistan)"
        case .ur: return "Urdu"
        case .uz_Arab: return "Uzbek (Arabic)"
        case .uz_Arab_AF: return "Uzbek (Arabic, Afghanistan)"
        case .uz_Cyrl: return "Uzbek (Cyrillic)"
        case .uz_Cyrl_UZ: return "Uzbek (Cyrillic, Uzbekistan)"
        case .uz_Latn: return "Uzbek (Latin)"
        case .uz_Latn_UZ: return "Uzbek (Latin, Uzbekistan)"
        case .uz: return "Uzbek"
        case .vi_VN: return "Vietnamese (Vietnam)"
        case .vi: return "Vietnamese"
        case .vun_TZ: return "Vunjo (Tanzania)"
        case .vun: return "Vunjo"
        case .cy_GB: return "Welsh (United Kingdom)"
        case .cy: return "Welsh"
        case .yo_NG: return "Yoruba (Nigeria)"
        case .yo: return "Yoruba"
        case .zu_ZA: return "Zulu (South Africa)"
        case .zu: return "Zulu"
        }
    }
}
#endif

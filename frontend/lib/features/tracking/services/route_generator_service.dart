import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/trip_details.dart';

/// Real road route geometry and distance/duration result
class RoadRouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final int durationMinutes;

  const RoadRouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
  });
}

/// Place category for filtering
class PlaceItem {
  final String id;
  final String name;
  final String category; // e.g., 'Colombo', 'Suburbs', 'Gampaha', 'Kandy', etc.
  final double latitude;
  final double longitude;

  const PlaceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
  });

  BusStop toBusStop({int order = 1}) {
    return BusStop(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      order: order,
    );
  }
}

/// Service to geocode Sri Lankan schools & pickup locations and generate
/// dynamic, realistic auto-routes for any registered child.
class RouteGeneratorService {
  // =========================================================================
  // 1. ALL PROMINENT SCHOOLS IN SRI LANKA (National, Private, International)
  // =========================================================================
  static final List<PlaceItem> allSchoolsInSriLanka = [
    // --- Colombo Leading Boys' & Mixed Schools ---
    const PlaceItem(id: 'sch_royal', name: 'Royal College, Colombo 07', category: 'Colombo Leading', latitude: 6.9044, longitude: 79.8622),
    const PlaceItem(id: 'sch_ananda', name: 'Ananda College, Colombo 10', category: 'Colombo Leading', latitude: 6.9298, longitude: 79.8705),
    const PlaceItem(id: 'sch_nalanda', name: 'Nalanda College, Colombo 10', category: 'Colombo Leading', latitude: 6.9320, longitude: 79.8730),
    const PlaceItem(id: 'sch_ds', name: 'D.S. Senanayake College, Colombo 07', category: 'Colombo Leading', latitude: 6.9040, longitude: 79.8740),
    const PlaceItem(id: 'sch_mahanama', name: 'Mahanama College, Colombo 03', category: 'Colombo Leading', latitude: 6.9010, longitude: 79.8620),
    const PlaceItem(id: 'sch_thurstan', name: 'Thurstan College, Colombo 07', category: 'Colombo Leading', latitude: 6.9030, longitude: 79.8600),
    const PlaceItem(id: 'sch_isipathana', name: 'Isipathana College, Colombo 05', category: 'Colombo Leading', latitude: 6.8870, longitude: 79.8670),
    const PlaceItem(id: 'sch_st_joseph', name: 'St. Joseph\'s College, Colombo 10', category: 'Colombo Leading', latitude: 6.9240, longitude: 79.8660),
    const PlaceItem(id: 'sch_st_peter', name: 'St. Peter\'s College, Colombo 04', category: 'Colombo Leading', latitude: 6.8850, longitude: 79.8610),
    const PlaceItem(id: 'sch_st_benedict', name: 'St. Benedict\'s College, Kotahena', category: 'Colombo Leading', latitude: 6.9450, longitude: 79.8640),
    const PlaceItem(id: 'sch_wesley', name: 'Wesley College, Colombo 09', category: 'Colombo Leading', latitude: 6.9220, longitude: 79.8790),
    const PlaceItem(id: 'sch_zahira', name: 'Zahira College, Colombo 10', category: 'Colombo Leading', latitude: 6.9330, longitude: 79.8640),
    const PlaceItem(id: 'sch_carey', name: 'Carey College, Colombo 08', category: 'Colombo Leading', latitude: 6.9250, longitude: 79.8730),
    const PlaceItem(id: 'sch_hindu_colombo', name: 'Colombo Hindu College, Bambalapitiya', category: 'Colombo Leading', latitude: 6.8810, longitude: 79.8600),

    // --- Colombo Leading Girls' Schools ---
    const PlaceItem(id: 'sch_visakha', name: 'Visakha Vidyalaya, Colombo 04', category: 'Girls\' Schools', latitude: 6.8920, longitude: 79.8600),
    const PlaceItem(id: 'sch_devi_balika', name: 'Devi Balika Vidyalaya, Colombo 08', category: 'Girls\' Schools', latitude: 6.9140, longitude: 79.8820),
    const PlaceItem(id: 'sch_sirimavo', name: 'Sirimavo Bandaranaike Vidyalaya, Colombo 07', category: 'Girls\' Schools', latitude: 6.8970, longitude: 79.8650),
    const PlaceItem(id: 'sch_musaeus', name: 'Musaeus College, Colombo 07', category: 'Girls\' Schools', latitude: 6.9120, longitude: 79.8620),
    const PlaceItem(id: 'sch_ladies', name: 'Ladies\' College, Colombo 07', category: 'Girls\' Schools', latitude: 6.9110, longitude: 79.8550),
    const PlaceItem(id: 'sch_bishop', name: 'Bishop\'s College, Colombo 03', category: 'Girls\' Schools', latitude: 6.9160, longitude: 79.8540),
    const PlaceItem(id: 'sch_methodist', name: 'Methodist College, Colombo 03', category: 'Girls\' Schools', latitude: 6.9180, longitude: 79.8510),
    const PlaceItem(id: 'sch_hfc_bamba', name: 'Holy Family Convent, Bambalapitiya', category: 'Girls\' Schools', latitude: 6.8910, longitude: 79.8550),
    const PlaceItem(id: 'sch_st_bridget', name: 'St. Bridget\'s Convent, Colombo 07', category: 'Girls\' Schools', latitude: 6.9150, longitude: 79.8640),
    const PlaceItem(id: 'sch_st_paul', name: 'St. Paul\'s Girls\' School, Milagiriya', category: 'Girls\' Schools', latitude: 6.8930, longitude: 79.8590),
    const PlaceItem(id: 'sch_anula', name: 'Anula Vidyalaya, Nugegoda', category: 'Girls\' Schools', latitude: 6.8730, longitude: 79.8940),
    const PlaceItem(id: 'sch_samudradevi', name: 'Samudradevi Balika Vidyalaya, Nugegoda', category: 'Girls\' Schools', latitude: 6.8710, longitude: 79.8960),
    const PlaceItem(id: 'sch_yashodhara', name: 'Yashodhara Balika Vidyalaya, Colombo 08', category: 'Girls\' Schools', latitude: 6.9210, longitude: 79.8760),
    const PlaceItem(id: 'sch_gothami', name: 'Gothami Balika Vidyalaya, Colombo 10', category: 'Girls\' Schools', latitude: 6.9260, longitude: 79.8750),
    const PlaceItem(id: 'sch_lindsay', name: 'Lindsay Girls\' School, Bambalapitiya', category: 'Girls\' Schools', latitude: 6.8920, longitude: 79.8580),
    const PlaceItem(id: 'sch_ilma', name: 'Ilma International Girls\' School, Colombo 05', category: 'Girls\' Schools', latitude: 6.8880, longitude: 79.8720),
    const PlaceItem(id: 'sch_muslim_ladies', name: 'Muslim Ladies\' College, Bambalapitiya', category: 'Girls\' Schools', latitude: 6.8890, longitude: 79.8570),

    // --- Suburbs, Moratuwa & Mount Lavinia ---
    const PlaceItem(id: 'sch_st_thomas_ml', name: 'S. Thomas\' College, Mount Lavinia', category: 'Suburbs & South', latitude: 6.8380, longitude: 79.8670),
    const PlaceItem(id: 'sch_st_thomas_prep', name: 'S. Thomas\' Preparatory School, Kollupitiya', category: 'Suburbs & South', latitude: 6.9130, longitude: 79.8510),
    const PlaceItem(id: 'sch_prince_wales', name: 'Prince of Wales\' College, Moratuwa', category: 'Suburbs & South', latitude: 6.7760, longitude: 79.8830),
    const PlaceItem(id: 'sch_princess_wales', name: 'Princess of Wales\' College, Moratuwa', category: 'Suburbs & South', latitude: 6.7740, longitude: 79.8820),
    const PlaceItem(id: 'sch_st_sebastian_mor', name: 'St. Sebastian\'s College, Moratuwa', category: 'Suburbs & South', latitude: 6.7720, longitude: 79.8850),
    const PlaceItem(id: 'sch_dharmapala', name: 'Dharmapala Vidyalaya, Pannipitiya', category: 'Suburbs & South', latitude: 6.8530, longitude: 79.9430),
    const PlaceItem(id: 'sch_president_mah', name: 'President\'s College, Maharagama', category: 'Suburbs & South', latitude: 6.8470, longitude: 79.9280),
    const PlaceItem(id: 'sch_sj_kotte', name: 'Sri Jayawardenepura Maha Vidyalaya, Kotte', category: 'Suburbs & South', latitude: 6.9020, longitude: 79.9050),
    const PlaceItem(id: 'sch_vidura', name: 'Vidura College, Nawala', category: 'Suburbs & South', latitude: 6.8940, longitude: 79.8860),

    // --- International Schools ---
    const PlaceItem(id: 'sch_gateway_raj', name: 'Gateway College, Rajagiriya', category: 'International', latitude: 6.9080, longitude: 79.8970),
    const PlaceItem(id: 'sch_gateway_deh', name: 'Gateway College, Dehiwala', category: 'International', latitude: 6.8490, longitude: 79.8690),
    const PlaceItem(id: 'sch_gateway_kandy', name: 'Gateway College, Kandy', category: 'International', latitude: 7.2850, longitude: 80.6410),
    const PlaceItem(id: 'sch_gateway_neg', name: 'Gateway College, Negombo', category: 'International', latitude: 7.2080, longitude: 79.8450),
    const PlaceItem(id: 'sch_cis_col', name: 'Colombo International School (CIS)', category: 'International', latitude: 6.8980, longitude: 79.8670),
    const PlaceItem(id: 'sch_cis_kandy', name: 'Colombo International School (CIS), Kandy', category: 'International', latitude: 7.2790, longitude: 80.6280),
    const PlaceItem(id: 'sch_elizabeth_moir', name: 'Elizabeth Moir School, Colombo 05', category: 'International', latitude: 6.8890, longitude: 79.8640),
    const PlaceItem(id: 'sch_british_school', name: 'The British School in Colombo, Colombo 08', category: 'International', latitude: 6.9110, longitude: 79.8830),
    const PlaceItem(id: 'sch_overseas_school', name: 'Overseas School of Colombo, Pelawatte', category: 'International', latitude: 6.8930, longitude: 79.9290),
    const PlaceItem(id: 'sch_lyceum_nug', name: 'Lyceum International School, Nugegoda', category: 'International', latitude: 6.8760, longitude: 79.8950),
    const PlaceItem(id: 'sch_lyceum_wat', name: 'Lyceum International School, Wattala', category: 'International', latitude: 6.9850, longitude: 79.8940),
    const PlaceItem(id: 'sch_lyceum_pan', name: 'Lyceum International School, Panadura', category: 'International', latitude: 6.7150, longitude: 79.9080),
    const PlaceItem(id: 'sch_lyceum_gam', name: 'Lyceum International School, Gampaha', category: 'International', latitude: 7.0910, longitude: 79.9960),
    const PlaceItem(id: 'sch_lyceum_rat', name: 'Lyceum International School, Ratnapura', category: 'International', latitude: 6.6850, longitude: 80.4010),
    const PlaceItem(id: 'sch_ais', name: 'Asian International School (AIS), Colombo 05', category: 'International', latitude: 6.8890, longitude: 79.8690),
    const PlaceItem(id: 'sch_stafford', name: 'Stafford International School, Colombo 07', category: 'International', latitude: 6.9000, longitude: 79.8680),
    const PlaceItem(id: 'sch_wycherley', name: 'Wycherley International School, Colombo 07', category: 'International', latitude: 6.9010, longitude: 79.8600),
    const PlaceItem(id: 'sch_royal_inst', name: 'Royal Institute International, Havelock', category: 'International', latitude: 6.8840, longitude: 79.8660),

    // --- Gampaha & Negombo Schools ---
    const PlaceItem(id: 'sch_bandaranayake_gam', name: 'Bandaranayake College, Gampaha', category: 'Gampaha & Negombo', latitude: 7.0920, longitude: 79.9980),
    const PlaceItem(id: 'sch_rathnavali_gam', name: 'Rathnavali Balika Vidyalaya, Gampaha', category: 'Gampaha & Negombo', latitude: 7.0890, longitude: 79.9940),
    const PlaceItem(id: 'sch_maris_stella', name: 'Maris Stella College, Negombo', category: 'Gampaha & Negombo', latitude: 7.2120, longitude: 79.8480),
    const PlaceItem(id: 'sch_ave_maria', name: 'Ave Maria Convent, Negombo', category: 'Gampaha & Negombo', latitude: 7.2100, longitude: 79.8440),
    const PlaceItem(id: 'sch_holy_cross_gam', name: 'Holy Cross College, Gampaha', category: 'Gampaha & Negombo', latitude: 7.0870, longitude: 79.9930),
    const PlaceItem(id: 'sch_gurukula_kel', name: 'Gurukula Vidyalaya, Kelaniya', category: 'Gampaha & Negombo', latitude: 6.9550, longitude: 79.9140),
    const PlaceItem(id: 'sch_dharmaloka_kel', name: 'Sri Dharmaloka College, Kelaniya', category: 'Gampaha & Negombo', latitude: 6.9580, longitude: 79.9180),
    const PlaceItem(id: 'sch_st_anthony_wat', name: 'St. Anthony\'s College, Wattala', category: 'Gampaha & Negombo', latitude: 6.9880, longitude: 79.8920),
    const PlaceItem(id: 'sch_newstead_neg', name: 'Newstead Girls\' College, Negombo', category: 'Gampaha & Negombo', latitude: 7.2140, longitude: 79.8420),

    // --- Kandy & Central Schools ---
    const PlaceItem(id: 'sch_trinity_kandy', name: 'Trinity College, Kandy', category: 'Kandy & Central', latitude: 7.2970, longitude: 80.6350),
    const PlaceItem(id: 'sch_dharmaraja_kandy', name: 'Dharmaraja College, Kandy', category: 'Kandy & Central', latitude: 7.2910, longitude: 80.6480),
    const PlaceItem(id: 'sch_kingswood_kandy', name: 'Kingswood College, Kandy', category: 'Kandy & Central', latitude: 7.2820, longitude: 80.6190),
    const PlaceItem(id: 'sch_st_anthony_kat', name: 'St. Anthony\'s College, Katugastota', category: 'Kandy & Central', latitude: 7.3210, longitude: 80.6230),
    const PlaceItem(id: 'sch_girls_high_kandy', name: 'Girls\' High School, Kandy', category: 'Kandy & Central', latitude: 7.2920, longitude: 80.6270),
    const PlaceItem(id: 'sch_mahamaya_kandy', name: 'Mahamaya Girls\' College, Kandy', category: 'Kandy & Central', latitude: 7.2890, longitude: 80.6430),
    const PlaceItem(id: 'sch_hillwood_kandy', name: 'Hillwood College, Kandy', category: 'Kandy & Central', latitude: 7.2880, longitude: 80.6400),
    const PlaceItem(id: 'sch_st_sylvester_kandy', name: 'St. Sylvester\'s College, Kandy', category: 'Kandy & Central', latitude: 7.2940, longitude: 80.6330),
    const PlaceItem(id: 'sch_pushpadana_kandy', name: 'Pushpadana Girls\' College, Kandy', category: 'Kandy & Central', latitude: 7.2950, longitude: 80.6380),
    const PlaceItem(id: 'sch_vidyartha_kandy', name: 'Vidyartha College, Kandy', category: 'Kandy & Central', latitude: 7.3030, longitude: 80.6280),

    // --- Galle & Southern Schools ---
    const PlaceItem(id: 'sch_richmond_galle', name: 'Richmond College, Galle', category: 'Southern Province', latitude: 6.0530, longitude: 80.2110),
    const PlaceItem(id: 'sch_mahinda_galle', name: 'Mahinda College, Galle', category: 'Southern Province', latitude: 6.0460, longitude: 80.2180),
    const PlaceItem(id: 'sch_southlands_galle', name: 'Southlands College, Galle Fort', category: 'Southern Province', latitude: 6.0270, longitude: 80.2160),
    const PlaceItem(id: 'sch_aloysius_galle', name: 'St. Aloysius\' College, Galle', category: 'Southern Province', latitude: 6.0350, longitude: 80.2150),
    const PlaceItem(id: 'sch_sanghamitta_galle', name: 'Sanghamitta Balika Vidyalaya, Galle', category: 'Southern Province', latitude: 6.0420, longitude: 80.2190),
    const PlaceItem(id: 'sch_rahula_matara', name: 'Rahula College, Matara', category: 'Southern Province', latitude: 5.9490, longitude: 80.5480),
    const PlaceItem(id: 'sch_sujatha_matara', name: 'Sujatha Vidyalaya, Matara', category: 'Southern Province', latitude: 5.9450, longitude: 80.5450),
    const PlaceItem(id: 'sch_st_thomas_matara', name: 'St. Thomas\' College, Matara', category: 'Southern Province', latitude: 5.9480, longitude: 80.5420),
    const PlaceItem(id: 'sch_st_servatius_matara', name: 'St. Servatius\' College, Matara', category: 'Southern Province', latitude: 5.9440, longitude: 80.5510),

    // --- Kurunegala Schools ---
    const PlaceItem(id: 'sch_maliyadeva_kur', name: 'Maliyadeva College, Kurunegala', category: 'North Western', latitude: 7.4880, longitude: 80.3620),
    const PlaceItem(id: 'sch_maliyadeva_bal_kur', name: 'Maliyadeva Balika Vidyalaya, Kurunegala', category: 'North Western', latitude: 7.4850, longitude: 80.3640),
    const PlaceItem(id: 'sch_st_anne_kur', name: 'St. Anne\'s College, Kurunegala', category: 'North Western', latitude: 7.4840, longitude: 80.3600),
    const PlaceItem(id: 'sch_hfc_kur', name: 'Holy Family Convent, Kurunegala', category: 'North Western', latitude: 7.4820, longitude: 80.3630),

    // --- Kalutara Schools ---
    const PlaceItem(id: 'sch_holy_cross_kal', name: 'Holy Cross College, Kalutara', category: 'Kalutara & South', latitude: 6.5850, longitude: 79.9610),
    const PlaceItem(id: 'sch_kalutara_vid', name: 'Kalutara Vidyalaya, Kalutara', category: 'Kalutara & South', latitude: 6.5820, longitude: 79.9640),
    const PlaceItem(id: 'sch_kalutara_bal', name: 'Kalutara Balika Vidyalaya, Kalutara', category: 'Kalutara & South', latitude: 6.5800, longitude: 79.9660),
    const PlaceItem(id: 'sch_tissa_central', name: 'Tissa Central College, Kalutara', category: 'Kalutara & South', latitude: 6.5780, longitude: 79.9620),
    const PlaceItem(id: 'sch_sumangala_pan', name: 'Sri Sumangala College, Panadura', category: 'Kalutara & South', latitude: 6.7120, longitude: 79.9070),
    const PlaceItem(id: 'sch_sumangala_bal_pan', name: 'Sri Sumangala Balika, Panadura', category: 'Kalutara & South', latitude: 6.7140, longitude: 79.9050),

    // --- Northern & Eastern Province Schools ---
    const PlaceItem(id: 'sch_jaffna_hindu', name: 'Jaffna Hindu College, Jaffna', category: 'Northern & Eastern', latitude: 9.6680, longitude: 80.0150),
    const PlaceItem(id: 'sch_st_john_jaffna', name: 'St. John\'s College, Jaffna', category: 'Northern & Eastern', latitude: 9.6640, longitude: 80.0210),
    const PlaceItem(id: 'sch_hartley_ptp', name: 'Hartley College, Point Pedro', category: 'Northern & Eastern', latitude: 9.8240, longitude: 80.2310),
    const PlaceItem(id: 'sch_st_michael_bat', name: 'St. Michael\'s College, Batticaloa', category: 'Northern & Eastern', latitude: 7.7170, longitude: 81.6980),
    const PlaceItem(id: 'sch_vincent_bat', name: 'Vincent Girls\' High School, Batticaloa', category: 'Northern & Eastern', latitude: 7.7150, longitude: 81.7010),
  ];

  // =========================================================================
  // 2. ALL PROMINENT PICKUP PLACES & TOWNS ACROSS SRI LANKA
  // =========================================================================
  static final List<PlaceItem> allPickupPlacesInSriLanka = [
    // --- Colombo City (Colombo 01 - 15) ---
    const PlaceItem(id: 'pl_fort', name: 'Fort / Colombo 01', category: 'Colombo City', latitude: 6.9340, longitude: 79.8430),
    const PlaceItem(id: 'pl_slave_island', name: 'Slave Island / Colombo 02', category: 'Colombo City', latitude: 6.9220, longitude: 79.8510),
    const PlaceItem(id: 'pl_kollupitiya', name: 'Kollupitiya / Colombo 03', category: 'Colombo City', latitude: 6.9120, longitude: 79.8510),
    const PlaceItem(id: 'pl_bambalapitiya', name: 'Bambalapitiya / Colombo 04', category: 'Colombo City', latitude: 6.8940, longitude: 79.8560),
    const PlaceItem(id: 'pl_havelock', name: 'Havelock Town / Colombo 05', category: 'Colombo City', latitude: 6.8860, longitude: 79.8670),
    const PlaceItem(id: 'pl_thimbirigasyaya', name: 'Thimbirigasyaya / Colombo 05', category: 'Colombo City', latitude: 6.8930, longitude: 79.8720),
    const PlaceItem(id: 'pl_wellawatte', name: 'Wellawatte / Colombo 06', category: 'Colombo City', latitude: 6.8770, longitude: 79.8600),
    const PlaceItem(id: 'pl_cinnamon_gardens', name: 'Cinnamon Gardens / Colombo 07', category: 'Colombo City', latitude: 6.9080, longitude: 79.8680),
    const PlaceItem(id: 'pl_torrington', name: 'Torrington Square / Colombo 07', category: 'Colombo City', latitude: 6.9010, longitude: 79.8680),
    const PlaceItem(id: 'pl_horton_place', name: 'Horton Place / Colombo 07', category: 'Colombo City', latitude: 6.9100, longitude: 79.8700),
    const PlaceItem(id: 'pl_borella', name: 'Borella Junction / Colombo 08', category: 'Colombo City', latitude: 6.9140, longitude: 79.8770),
    const PlaceItem(id: 'pl_cotta_road', name: 'Cotta Road / Colombo 08', category: 'Colombo City', latitude: 6.9125, longitude: 79.8830),
    const PlaceItem(id: 'pl_dematagoda', name: 'Dematagoda Overpass / Colombo 09', category: 'Colombo City', latitude: 6.9290, longitude: 79.8900),
    const PlaceItem(id: 'pl_maradana', name: 'Maradana Railway / Colombo 10', category: 'Colombo City', latitude: 6.9300, longitude: 79.8680),
    const PlaceItem(id: 'pl_panchikawatte', name: 'Panchikawatte / Colombo 10', category: 'Colombo City', latitude: 6.9320, longitude: 79.8620),
    const PlaceItem(id: 'pl_pettah', name: 'Pettah Bus Stand / Colombo 11', category: 'Colombo City', latitude: 6.9380, longitude: 79.8530),
    const PlaceItem(id: 'pl_kotahena', name: 'Kotahena Junction / Colombo 13', category: 'Colombo City', latitude: 6.9450, longitude: 79.8650),
    const PlaceItem(id: 'pl_grandpass', name: 'Grandpass / Colombo 14', category: 'Colombo City', latitude: 6.9510, longitude: 79.8720),
    const PlaceItem(id: 'pl_mattakkuliya', name: 'Mattakkuliya / Colombo 15', category: 'Colombo City', latitude: 6.9720, longitude: 79.8750),

    // --- Suburbs & Greater Colombo ---
    const PlaceItem(id: 'pl_nawala', name: 'Nawala Road stop', category: 'Colombo Suburbs', latitude: 6.8960, longitude: 79.8870),
    const PlaceItem(id: 'pl_rajagiriya', name: 'Rajagiriya Junction stop', category: 'Colombo Suburbs', latitude: 6.9110, longitude: 79.8890),
    const PlaceItem(id: 'pl_narahenpita', name: 'Narahenpita Junction', category: 'Colombo Suburbs', latitude: 6.8990, longitude: 79.8780),
    const PlaceItem(id: 'pl_battaramulla', name: 'Battaramulla Junction', category: 'Colombo Suburbs', latitude: 6.8990, longitude: 79.9170),
    const PlaceItem(id: 'pl_pelawatte', name: 'Pelawatte (Parliament Road)', category: 'Colombo Suburbs', latitude: 6.8930, longitude: 79.9290),
    const PlaceItem(id: 'pl_malabe', name: 'Malabe Junction', category: 'Colombo Suburbs', latitude: 6.9040, longitude: 79.9540),
    const PlaceItem(id: 'pl_thalawathugoda', name: 'Thalawathugoda Junction', category: 'Colombo Suburbs', latitude: 6.8780, longitude: 79.9320),
    const PlaceItem(id: 'pl_hokandara', name: 'Hokandara Junction', category: 'Colombo Suburbs', latitude: 6.8690, longitude: 79.9480),
    const PlaceItem(id: 'pl_kottawa', name: 'Kottawa Junction', category: 'Colombo Suburbs', latitude: 6.8410, longitude: 79.9650),
    const PlaceItem(id: 'pl_maharagama', name: 'Maharagama Clock Tower', category: 'Colombo Suburbs', latitude: 6.8480, longitude: 79.9270),
    const PlaceItem(id: 'pl_pannipitiya', name: 'Pannipitiya Town Stop', category: 'Colombo Suburbs', latitude: 6.8520, longitude: 79.9410),
    const PlaceItem(id: 'pl_nugegoda', name: 'Nugegoda Flyover / Supermarket', category: 'Colombo Suburbs', latitude: 6.8720, longitude: 79.8920),
    const PlaceItem(id: 'pl_mirihana', name: 'Mirihana Police Junction', category: 'Colombo Suburbs', latitude: 6.8750, longitude: 79.9020),
    const PlaceItem(id: 'pl_delkanda', name: 'Delkanda Junction', category: 'Colombo Suburbs', latitude: 6.8660, longitude: 79.8990),
    const PlaceItem(id: 'pl_kohuwala', name: 'Kohuwala Junction', category: 'Colombo Suburbs', latitude: 6.8610, longitude: 79.8850),
    const PlaceItem(id: 'pl_kalubowila', name: 'Kalubowila Hospital Stop', category: 'Colombo Suburbs', latitude: 6.8680, longitude: 79.8770),
    const PlaceItem(id: 'pl_dehiwala', name: 'Dehiwala Zoo Road / Galle Road', category: 'Colombo Suburbs', latitude: 6.8520, longitude: 79.8670),
    const PlaceItem(id: 'pl_mount_lavinia', name: 'Mount Lavinia Hotel Road', category: 'Colombo Suburbs', latitude: 6.8360, longitude: 79.8650),
    const PlaceItem(id: 'pl_ratmalana', name: 'Ratmalana Airport Road', category: 'Colombo Suburbs', latitude: 6.8220, longitude: 79.8760),
    const PlaceItem(id: 'pl_moratuwa', name: 'Moratuwa Cross Junction', category: 'Colombo Suburbs', latitude: 6.7740, longitude: 79.8820),
    const PlaceItem(id: 'pl_rawathawatte', name: 'Rawathawatte / Moratuwa', category: 'Colombo Suburbs', latitude: 6.7860, longitude: 79.8830),
    const PlaceItem(id: 'pl_homagama', name: 'Homagama Town Stop', category: 'Colombo Suburbs', latitude: 6.8430, longitude: 80.0020),
    const PlaceItem(id: 'pl_athurugiriya', name: 'Athurugiriya Clock Tower', category: 'Colombo Suburbs', latitude: 6.8720, longitude: 79.9880),
    const PlaceItem(id: 'pl_kaduwela', name: 'Kaduwela Town Stop', category: 'Colombo Suburbs', latitude: 6.9340, longitude: 79.9840),

    // --- Gampaha & Negombo Corridor ---
    const PlaceItem(id: 'pl_wattala', name: 'Wattala Junction (Main Road)', category: 'Gampaha & Negombo', latitude: 6.9890, longitude: 79.8910),
    const PlaceItem(id: 'pl_mabole', name: 'Mabole / Negombo Road', category: 'Gampaha & Negombo', latitude: 6.9810, longitude: 79.8930),
    const PlaceItem(id: 'pl_peliyagoda', name: 'Peliyagoda Interchange', category: 'Gampaha & Negombo', latitude: 6.9650, longitude: 79.9050),
    const PlaceItem(id: 'pl_kelaniya', name: 'Kelaniya Temple Road', category: 'Gampaha & Negombo', latitude: 6.9530, longitude: 79.9160),
    const PlaceItem(id: 'pl_kiribathgoda', name: 'Kiribathgoda Town Stop', category: 'Gampaha & Negombo', latitude: 6.9790, longitude: 79.9280),
    const PlaceItem(id: 'pl_kadawatha', name: 'Kadawatha Bus Stand / Expressway', category: 'Gampaha & Negombo', latitude: 7.0010, longitude: 79.9520),
    const PlaceItem(id: 'pl_mahabage', name: 'Mahabage Junction', category: 'Gampaha & Negombo', latitude: 6.9980, longitude: 79.8920),
    const PlaceItem(id: 'pl_kandana', name: 'Kandana Town Stop', category: 'Gampaha & Negombo', latitude: 7.0480, longitude: 79.8960),
    const PlaceItem(id: 'pl_ja_ela', name: 'Ja-Ela Clock Tower', category: 'Gampaha & Negombo', latitude: 7.0750, longitude: 79.8920),
    const PlaceItem(id: 'pl_seeduwa', name: 'Seeduwa / Katunayake', category: 'Gampaha & Negombo', latitude: 7.1420, longitude: 79.8720),
    const PlaceItem(id: 'pl_negombo', name: 'Negombo Town Bus Stand', category: 'Gampaha & Negombo', latitude: 7.2110, longitude: 79.8460),
    const PlaceItem(id: 'pl_gampaha', name: 'Gampaha Railway Station', category: 'Gampaha & Negombo', latitude: 7.0910, longitude: 79.9960),
    const PlaceItem(id: 'pl_yakkala', name: 'Yakkala Junction', category: 'Gampaha & Negombo', latitude: 7.0850, longitude: 80.0350),
    const PlaceItem(id: 'pl_nittambuwa', name: 'Nittambuwa Junction', category: 'Gampaha & Negombo', latitude: 7.1440, longitude: 80.1030),
    const PlaceItem(id: 'pl_mirigama', name: 'Mirigama Town', category: 'Gampaha & Negombo', latitude: 7.2430, longitude: 80.1290),

    // --- Kalutara & Southern Coastal Corridor ---
    const PlaceItem(id: 'pl_panadura', name: 'Panadura Town Bus Stand', category: 'Kalutara & South', latitude: 6.7150, longitude: 79.9070),
    const PlaceItem(id: 'pl_wadduwa', name: 'Wadduwa Junction', category: 'Kalutara & South', latitude: 6.6630, longitude: 79.9290),
    const PlaceItem(id: 'pl_kalutara_north', name: 'Kalutara North Bridge', category: 'Kalutara & South', latitude: 6.5850, longitude: 79.9610),
    const PlaceItem(id: 'pl_kalutara_south', name: 'Kalutara South Clock Tower', category: 'Kalutara & South', latitude: 6.5780, longitude: 79.9620),
    const PlaceItem(id: 'pl_beruwala', name: 'Beruwala Town Stop', category: 'Kalutara & South', latitude: 6.4780, longitude: 79.9820),
    const PlaceItem(id: 'pl_aluthgama', name: 'Aluthgama Bus Stand', category: 'Kalutara & South', latitude: 6.4320, longitude: 79.9990),
    const PlaceItem(id: 'pl_bentota', name: 'Bentota Bridge', category: 'Kalutara & South', latitude: 6.4250, longitude: 80.0030),
    const PlaceItem(id: 'pl_ambalangoda', name: 'Ambalangoda Town Stop', category: 'Kalutara & South', latitude: 6.2360, longitude: 80.0540),
    const PlaceItem(id: 'pl_hikkaduwa', name: 'Hikkaduwa Town', category: 'Kalutara & South', latitude: 6.1410, longitude: 80.1010),
    const PlaceItem(id: 'pl_galle', name: 'Galle Central Bus Stand', category: 'Kalutara & South', latitude: 6.0350, longitude: 80.2150),
    const PlaceItem(id: 'pl_unawatuna', name: 'Unawatuna Junction', category: 'Kalutara & South', latitude: 6.0120, longitude: 80.2480),
    const PlaceItem(id: 'pl_matara', name: 'Matara Town Stand', category: 'Kalutara & South', latitude: 5.9480, longitude: 80.5420),

    // --- Kandy & Central Corridor ---
    const PlaceItem(id: 'pl_kandy_clock', name: 'Kandy Clock Tower Stand', category: 'Kandy & Central', latitude: 7.2920, longitude: 80.6330),
    const PlaceItem(id: 'pl_peradeniya', name: 'Peradeniya Junction', category: 'Kandy & Central', latitude: 7.2620, longitude: 80.5960),
    const PlaceItem(id: 'pl_katugastota', name: 'Katugastota Bridge', category: 'Kandy & Central', latitude: 7.3210, longitude: 80.6230),
    const PlaceItem(id: 'pl_gampola', name: 'Gampola Town', category: 'Kandy & Central', latitude: 7.1640, longitude: 80.5690),
    const PlaceItem(id: 'pl_kegalle', name: 'Kegalle Town', category: 'Kandy & Central', latitude: 7.2510, longitude: 80.3460),
    const PlaceItem(id: 'pl_mawanella', name: 'Mawanella Town', category: 'Kandy & Central', latitude: 7.2520, longitude: 80.4480),

    // --- Other Major Island Cities ---
    const PlaceItem(id: 'pl_kurunegala', name: 'Kurunegala Central Bus Stand', category: 'Other Districts', latitude: 7.4860, longitude: 80.3640),
    const PlaceItem(id: 'pl_kuliyapitiya', name: 'Kuliyapitiya Town', category: 'Other Districts', latitude: 7.4690, longitude: 80.0410),
    const PlaceItem(id: 'pl_ratnapura', name: 'Ratnapura Clock Tower', category: 'Other Districts', latitude: 6.6850, longitude: 80.4010),
    const PlaceItem(id: 'pl_avissawella', name: 'Avissawella Town Stop', category: 'Other Districts', latitude: 6.9530, longitude: 80.2120),
    const PlaceItem(id: 'pl_anuradhapura', name: 'Anuradhapura New Town', category: 'Other Districts', latitude: 8.3110, longitude: 80.4030),
    const PlaceItem(id: 'pl_dambulla', name: 'Dambulla Clock Tower', category: 'Other Districts', latitude: 7.8600, longitude: 80.6520),
    const PlaceItem(id: 'pl_badulla', name: 'Badulla Town Stand', category: 'Other Districts', latitude: 6.9890, longitude: 81.0560),
    const PlaceItem(id: 'pl_bandarawela', name: 'Bandarawela Town', category: 'Other Districts', latitude: 6.8330, longitude: 80.9850),
    const PlaceItem(id: 'pl_nuwara_eliya', name: 'Nuwara Eliya Post Office', category: 'Other Districts', latitude: 6.9690, longitude: 80.7710),
    const PlaceItem(id: 'pl_jaffna', name: 'Jaffna Central Bus Stand', category: 'Other Districts', latitude: 9.6630, longitude: 80.0170),
    const PlaceItem(id: 'pl_trincomalee', name: 'Trincomalee Clock Tower', category: 'Other Districts', latitude: 8.5870, longitude: 81.2150),
    const PlaceItem(id: 'pl_batticaloa', name: 'Batticaloa Central Stand', category: 'Other Districts', latitude: 7.7170, longitude: 81.6980),
  ];

  /// Geocode any place name string (school or pickup location) into a LatLng
  static LatLng geocodePlace(String placeName, {bool isSchool = false}) {
    final lower = placeName.toLowerCase().trim();

    // 1. Exact match on school
    if (isSchool) {
      for (final item in allSchoolsInSriLanka) {
        if (item.name.toLowerCase() == lower) {
          return LatLng(item.latitude, item.longitude);
        }
      }
    }

    // 2. Exact match on pickup place
    for (final item in allPickupPlacesInSriLanka) {
      if (item.name.toLowerCase() == lower) {
        return LatLng(item.latitude, item.longitude);
      }
    }

    // 3. Token-based match ignoring generic stop words
    const stopWords = {
      'college', 'school', 'vidyalaya', 'convent', 'international',
      'town', 'stop', 'road', 'junction', 'street', 'avenue', 'place',
      'station', 'bus', 'stand', 'central', 'main', 'gate', 'bridge',
      'colombo', 'the', 'and', 'for', 'near', 'approach', 'city'
    };

    final tokens = lower
        .split(RegExp(r'[\s,\(\)\/\-\.]+'))
        .map((s) => s.trim())
        .where((s) => s.length >= 3 && !stopWords.contains(s))
        .toList();

    if (isSchool) {
      for (final item in allSchoolsInSriLanka) {
        final targetLower = item.name.toLowerCase();
        for (final token in tokens) {
          if (targetLower.contains(token)) {
            return LatLng(item.latitude, item.longitude);
          }
        }
      }
    }

    for (final item in allPickupPlacesInSriLanka) {
      final targetLower = item.name.toLowerCase();
      for (final token in tokens) {
        if (targetLower.contains(token)) {
          return LatLng(item.latitude, item.longitude);
        }
      }
    }

    if (!isSchool) {
      for (final item in allSchoolsInSriLanka) {
        final targetLower = item.name.toLowerCase();
        for (final token in tokens) {
          if (targetLower.contains(token)) {
            return LatLng(item.latitude, item.longitude);
          }
        }
      }
    }

    // 4. Default Colombo area fallback with deterministic jitter
    final hash = lower.codeUnits.fold(0, (prev, elem) => prev + elem);
    final latOffset = ((hash % 100) - 50) * 0.0004;
    final lngOffset = (((hash ~/ 100) % 100) - 50) * 0.0004;
    return LatLng(6.9100 + latOffset, 79.8700 + lngOffset);
  }

  /// Generate a realistic multi-point auto-route polyline between pickup & destination
  static List<LatLng> generateAutoRoute({
    required LatLng pickup,
    required LatLng destination,
  }) {
    final points = <LatLng>[pickup];

    final latDiff = destination.latitude - pickup.latitude;
    final lngDiff = destination.longitude - pickup.longitude;

    // Create 4 realistic intermediate transit road bends
    points.add(LatLng(
      pickup.latitude + (latDiff * 0.18),
      pickup.longitude + (lngDiff * 0.05),
    ));

    points.add(LatLng(
      pickup.latitude + (latDiff * 0.45),
      pickup.longitude + (lngDiff * 0.38),
    ));

    points.add(LatLng(
      pickup.latitude + (latDiff * 0.72),
      pickup.longitude + (lngDiff * 0.65),
    ));

    points.add(LatLng(
      pickup.latitude + (latDiff * 0.90),
      pickup.longitude + (lngDiff * 0.92),
    ));

    points.add(destination);
    return points;
  }

  /// Fetch real road route geometry from OSRM driving service
  /// Returns actual curved street geometry with hundreds of coordinate points
  static Future<RoadRouteResult> fetchRealRoadRoute({
    required LatLng pickup,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${pickup.longitude},${pickup.latitude};${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes.first;
          final geometry = route['geometry'] as Map<String, dynamic>?;
          final coordinates = geometry?['coordinates'] as List?;

          if (coordinates != null && coordinates.isNotEmpty) {
            final List<LatLng> roadPoints = [];
            for (final coord in coordinates) {
              if (coord is List && coord.length >= 2) {
                // GeoJSON format is [longitude, latitude]
                final lng = (coord[0] as num).toDouble();
                final lat = (coord[1] as num).toDouble();
                roadPoints.add(LatLng(lat, lng));
              }
            }

            final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
            final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;

            if (roadPoints.length >= 2) {
              return RoadRouteResult(
                points: roadPoints,
                distanceKm: (distanceMeters / 1000),
                durationMinutes: (durationSeconds / 60).round(),
              );
            }
          }
        }
      }
    } catch (_) {
      // Fallback below if network is momentarily unavailable
    }

    final fallbackPoints = generateAutoRoute(pickup: pickup, destination: destination);
    return RoadRouteResult(
      points: fallbackPoints,
      distanceKm: 12.0,
      durationMinutes: 25,
    );
  }

  /// Generate intermediate stops for display
  static List<BusStop> generateIntermediateStops({
    required LatLng pickup,
    required LatLng destination,
    required String pickupName,
    required String schoolName,
  }) {
    final latDiff = destination.latitude - pickup.latitude;
    final lngDiff = destination.longitude - pickup.longitude;

    return [
      BusStop(
        id: 'child_pickup',
        name: pickupName,
        latitude: pickup.latitude,
        longitude: pickup.longitude,
        order: 1,
      ),
      BusStop(
        id: 'waypoint_1',
        name: 'Transit Arterial Waypoint',
        latitude: pickup.latitude + (latDiff * 0.45),
        longitude: pickup.longitude + (lngDiff * 0.38),
        order: 2,
      ),
      BusStop(
        id: 'waypoint_2',
        name: 'School Approach Waypoint',
        latitude: pickup.latitude + (latDiff * 0.78),
        longitude: pickup.longitude + (lngDiff * 0.70),
        order: 3,
      ),
      BusStop(
        id: 'child_destination',
        name: schoolName,
        latitude: destination.latitude,
        longitude: destination.longitude,
        order: 4,
      ),
    ];
  }

  /// Calculate compass bearing (degrees: 0 - 360) from start to end coordinate
  static double calculateBearing(LatLng start, LatLng end) {
    final startLat = start.latitude * (pi / 180.0);
    final startLng = start.longitude * (pi / 180.0);
    final endLat = end.latitude * (pi / 180.0);
    final endLng = end.longitude * (pi / 180.0);

    final dLng = endLng - startLng;
    final y = sin(dLng) * cos(endLat);
    final x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);

    final brng = atan2(y, x) * (180.0 / pi);
    return (brng + 360.0) % 360.0;
  }
}

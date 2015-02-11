(function(RemoteMonitoring) {
  'use strict';

  function beginningOfWeek() {
    var now = new Date();
    now.setDate(now.getDate() - now.getDay());
    return now;
  }

  var jsMonthOffset = 1;

  RemoteMonitoring.fakeSensorData = {
    weeklyNormalFlow: {
      "deviceId": 1289600793682,
      "adc": 4212,
      "rssi": 71,
      "imei": 13949004634708,
      "values": {
        "weeklyLog": {
          "unitID": 1234,
          "version": 1,
          "week": 26,
          "GMTyear": beginningOfWeek().getFullYear(),
          "GMTmonth": beginningOfWeek().getMonth() + jsMonthOffset, // WHY
          "GMTday": beginningOfWeek().getDate(),
          "GMThour": 0,
          "GMTminute": 0,
          "GMTsecond": 0,
          "redFlag": 0,
          "dailyLogs": [
            {
            "liters": [0, 0, 0, 0, 0, 0, 7752, 7772, 7857, 7840, 7829, 7881,
              7866, 7906, 7893, 7775, 7824, 7824, 7766, 0, 0, 0, 0, 0],
              "padMax": [45030, 45521, 46025, 46522, 47010, 47509],
            "padMin": [43036, 43538, 44031, 44531, 45015, 45504],
            "padSubmerged": [3848, 4745, 3474, 4765, 4886, 3394],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 7794, 7825, 7873, 7859, 7946, 7769,
              8017, 7777, 7799, 7764, 7767, 7848, 7893, 0, 0, 0, 0, 0],
              "padMax": [45031, 45511, 46011, 46522, 47035, 47531],
            "padMin": [43021, 43532, 44000, 44519, 45006, 45509],
            "padSubmerged": [1801, 9123, 3426, 1763, 1002, 7523],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 7760, 7890, 7916, 7819, 7913, 7843,
              7905, 7810, 7763, 7802, 7764, 7821, 7808, 0, 0, 0, 0, 0],
              "padMax": [45017, 45503, 46004, 46502, 47002, 47517],
            "padMin": [43028, 43503, 44030, 44525, 45013, 45515],
            "padSubmerged": [8164, 9902, 7885, 8954, 358, 1182],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 7746, 7846, 7729, 7748, 7789, 7758,
              7772, 7767, 7670, 7895, 7943, 7942, 7921, 0, 0, 0, 0, 0],
              "padMax": [45005, 45509, 46001, 46507, 47008, 47529],
            "padMin": [43037, 43537, 44004, 44520, 45017, 45517],
            "padSubmerged": [9119, 8502, 7185, 208, 5860, 3862],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 7869, 7731, 7781, 7836, 7755, 7883,
              7919, 7755, 7726, 7856, 7831, 7862, 7803, 0, 0, 0, 0, 0],
              "padMax": [45018, 45502, 46024, 46528, 47038, 47524],
            "padMin": [43022, 43512, 44012, 44531, 45036, 45539],
            "padSubmerged": [1413, 4335, 8668, 2088, 5299, 5648],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 7757, 7850, 7974, 7841, 7803, 7982,
              7849, 7735, 7812, 7708, 7899, 7846, 7770, 0, 0, 0, 0, 0],
              "padMax": [45002, 45511, 46013, 46509, 47028, 47517],
            "padMin": [43030, 43524, 44027, 44504, 45014, 45506],
            "padSubmerged": [6839, 7669, 868, 705, 9192, 9452],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 7891, 7750, 7652, 7878, 7816, 7804,
              7826, 7873, 7769, 7820, 7733, 7780, 7853, 0, 0, 0, 0, 0],
              "padMax": [45018, 45531, 46013, 46502, 47038, 47519],
            "padMin": [43016, 43509, 44023, 44524, 45024, 45528],
            "padSubmerged": [3405, 5693, 775, 9652, 836, 482],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          }
          ]
        }
      }
    },
    weeklyRedFlag: {
      "deviceId": 1289600793682,
      "adc": 4212,
      "rssi": 71,
      "imei": 13949004634708,
      "values": {
        "weeklyLog": {
          "unitID": 1234,
          "version": 1,
          "week": 26,
          "GMTyear": beginningOfWeek().getFullYear(),
          "GMTmonth": beginningOfWeek().getMonth() + jsMonthOffset, // WHY
          "GMTday": beginningOfWeek().getDate(),
          "GMThour": 0,
          "GMTminute": 0,
          "GMTsecond": 0,
          "redFlag": 1,
          "dailyLogs": [
            {
            "liters": [200, 200, 200, 200, 200, 200, 202, 202, 207, 201, 209, 201, 206, 206, 203, 205, 204, 204,
              206, 200, 200, 200, 200, 200],
            "padMax": [45030, 45521, 46025, 46522, 47010, 47509],
            "padMin": [43036, 43538, 44031, 44531, 45015, 45504],
            "padSubmerged": [3848, 4745, 3474, 4765, 4886, 3394],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [200, 200, 200, 200, 200, 200, 204, 205, 203, 209, 206, 209, 207, 207, 209, 204, 207,
              208, 203, 200, 200, 200, 200, 200],
            "padMax": [45031, 45511, 46011, 46522, 47035, 47531],
            "padMin": [43021, 43532, 44000, 44519, 45006, 45509],
            "padSubmerged": [1801, 9123, 3426, 1763, 1002, 7523],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [200, 200, 200, 200, 200, 200, 200, 200, 206, 209, 203, 203, 205, 200, 203, 202, 204,
              201, 208, 200, 200, 200, 200, 200],
            "padMax": [45017, 45503, 46004, 46502, 47002, 47517],
            "padMin": [43028, 43503, 44030, 44525, 45013, 45515],
            "padSubmerged": [8164, 9902, 7885, 8954, 358, 1182],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [200, 200, 200, 200, 200, 200, 206, 206, 209, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0],
            "padMax": [45005, 45509, 46001, 46507, 47008, 47529],
            "padMin": [43037, 43537, 44004, 44520, 45017, 45517],
            "padSubmerged": [9119, 8502, 7185, 208, 5860, 3862],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 9, 1, 1, 6, 5, 3, 9, 5, 6, 6, 1,
              2, 3, 0, 0, 0, 0, 0],
            "padMax": [45018, 45502, 46024, 46528, 47038, 47524],
            "padMin": [43022, 43512, 44012, 44531, 45036, 45539],
            "padSubmerged": [1413, 4335, 8668, 2088, 5299, 5648],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 1
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 7, 0, 4, 1, 3, 2, 9, 5, 2, 8, 9,
              6, 0, 0, 0, 0, 0, 0],
            "padMax": [45002, 45511, 46013, 46509, 47028, 47517],
            "padMin": [43030, 43524, 44027, 44504, 45014, 45506],
            "padSubmerged": [6839, 7669, 868, 705, 9192, 9452],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 1, 0, 2, 8, 6, 4, 6, 3, 9, 0, 3,
              0, 3, 0, 0, 0, 0, 0],
            "padMax": [45018, 45531, 46013, 46502, 47038, 47519],
            "padMin": [43016, 43509, 44023, 44524, 45024, 45528],
            "padSubmerged": [3405, 5693, 775, 9652, 836, 482],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          }
          ]
        }
      }
    },
    outOfBandRedFlag: {
      "deviceId": 1289600793682,
      "adc": 4212,
      "rssi": 71,
      "imei": 13949004634708,
      "values": {
        "weeklyLog": {
          "unitID": 1234,
          "version": 1,
          "week": 26,
          "GMTyear": beginningOfWeek().getFullYear(),
          "GMTmonth": beginningOfWeek().getMonth() + jsMonthOffset, // WHY
          "GMTday": beginningOfWeek().getDate(),
          "GMThour": 0,
          "GMTminute": 0,
          "GMTsecond": 0,
          "redFlag": 255,
          "dailyLogs": [
            {
            "liters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0],
            "padMax": [0, 0, 0, 0, 0, 0],
            "padMin": [0, 0, 0, 0, 0, 0],
            "padSubmerged": [0, 0, 0, 0, 0, 0],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0],
            "padMax": [0, 0, 0, 0, 0, 0],
            "padMin": [0, 0, 0, 0, 0, 0],
            "padSubmerged": [0, 0, 0, 0, 0, 0],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0],
            "padMax": [0, 0, 0, 0, 0, 0],
            "padMin": [0, 0, 0, 0, 0, 0],
            "padSubmerged": [0, 0, 0, 0, 0, 0],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0],
            "padMax": [0, 0, 0, 0, 0, 0],
            "padMin": [0, 0, 0, 0, 0, 0],
            "padSubmerged": [0, 0, 0, 0, 0, 0],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0],
            "padMax": [0, 0, 0, 0, 0, 0],
            "padMin": [0, 0, 0, 0, 0, 0],
            "padSubmerged": [0, 0, 0, 0, 0, 0],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0],
            "padMax": [0, 0, 0, 0, 0, 0],
            "padMin": [0, 0, 0, 0, 0, 0],
            "padSubmerged": [0, 0, 0, 0, 0, 0],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          },
          {
            "liters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0],
            "padMax": [0, 0, 0, 0, 0, 0],
            "padMin": [0, 0, 0, 0, 0, 0],
            "padSubmerged": [0, 0, 0, 0, 0, 0],
            "comparedAverage": 0,
            "unknowns": 0,
            "overflow": 0,
            "redFlag": 0
          }
          ]
        }
      }
    }
  };
})(RemoteMonitoring);

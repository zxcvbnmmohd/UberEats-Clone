//
//  EarningsViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-22.
//

import UIKit
import Charts

class EarningsViewController: UIViewController {
    
    let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @IBOutlet weak var earningsChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initializeChart()
        self.loadDataToChart()
    }
    
    
    
    func initializeChart() {
        earningsChart.noDataText = "No Data"
        earningsChart.animate(yAxisDuration: 2.0, easingOption: .easeInBounce)
        earningsChart.xAxis.labelPosition = .bottom
        
        earningsChart.legend.enabled = false
        earningsChart.scaleXEnabled =  false
        earningsChart.scaleYEnabled = false
        earningsChart.pinchZoomEnabled = false
        earningsChart.doubleTapToZoomEnabled = false
        
        earningsChart.leftAxis.axisMinimum = 0
        earningsChart.leftAxis.axisMaximum = 500
        earningsChart.rightAxis.enabled = false
        earningsChart.xAxis.drawGridLinesEnabled = false
    }
    
    func loadDataToChart() {
        APIManager.shared.getDriverRevenue { json in
            print(json!)
            
            if json != nil {
                let revenue = json!["revenue"]
                
                var dataEntries: [BarChartDataEntry] = []
                for i in 0..<self.weekdays.count {
                    let day = self.weekdays[i]
                    let dataEntry = BarChartDataEntry(x: Double(i), y: revenue[day].double!)
                    dataEntries.append(dataEntry)
                }
                
                let chartDataSet = BarChartDataSet(entries: dataEntries, label: nil)
                chartDataSet.colors = ChartColorTemplates.material()
                
                let chartData = BarChartData(dataSet: chartDataSet)
                
                self.earningsChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.weekdays)
                self.earningsChart.data = chartData
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

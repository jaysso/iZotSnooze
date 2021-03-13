//
//  RecommendationAlgorithm.swift
//  iZotSnoozeTM
//
//  Created by Matthew Eng on 3/3/21.
//

import Foundation

class RecommendationAlgorithm {
    //Calculate average of test data array
    func average(_ input: [Float]) -> Float {
        return input.reduce(0,+) / Float(input.count)
    }

    func multiply(_ a: [Float], _ b: [Float]) -> [Float] {
        return zip(a,b).map(*)
    }

    //Returns LinReg line of test data points
    func linearRegression(_ xs: [Float], _ ys: [Float]) -> (Float,Float) {
        let sum1 = average(multiply(ys, xs)) - average(xs) * average(ys)
        let sum2 = average(multiply(xs, xs)) - pow(average(xs), 2)
        let slope = sum1 / sum2
        let yIntercept = average(ys) - slope * average(xs)
        return (yIntercept,slope)
    }

    // Input is (x,y) point, line is (y-int, slope)
    //  --Input X is Mood
    //  --Input Y is Time Slept/other attribute
    // Ex: (Mood=3, Hours Slept=8)
    // Assign as a dictionary [Attribute, Distance]
    func linRegComparison(_ input: (Float,Float), _ line: (Float,Float)) -> Float {
        let yReg = line.0 + line.1 * input.0
        let xReg = input.0
        var distance = sqrt(pow( (xReg-input.0) ,2) + pow( (yReg-input.1) ,2))
        if input.1<0 {distance *= -1.0}
        return distance
    }
}

// Factors the "weight"(importance) of each sleep attribute
//      returns dict of [attribute : weighted difference]
func weightedDifferences(differences: [String:Double], weights: [String:Double]) -> [String:Double]{
    var result = [String:Double]()
    for pair in differences {
        result[pair.key] = pair.value * (weights[pair.key])!
    }
    return result
}

// Turns raw differences into % difference
func percentDiff(diff: Double, testVal: Double) -> Double {
    return (diff)/testVal
}


//
//  RecommendationStrings.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 3/3/21.
//

import Foundation

class RecommendationString{
    // FUNC OF RECCOMENDATIONS -> [String] to sort in switch cases based on how extreme
    func SleepRec() -> [String]{
        
        let string0 =
            """
            We recommend adjusting your schedule to
            sleep between the hours of 8:00PM and
            midnight for optimum sleep.
            """
        let string1 =
            """
            For users in your age group 18-22, we
            recommend sleeping for 7-9 hours.
            """
        let string2 =
            """
            Try optimizing your bedroom environment
            like adjusting your noise, external
            lights, and furniture arrangements.
            """
        let string3 =
            """
            Try exercising regularly — but not before
            bed.
            """
        let string4 =
            """
            Try using a sleep mask when you sleep to
            reduce artifical light that may interrupt
            your sleep patterns.
            """
        let string5 =
            """
            We reccommend reducing blue light
            exposure in the evening.
            """
        let string6 =
            """
            Try reducing irregular or long daytime
            naps.
            """
        let string7 =
            """
            Try setting your bedroom temperature to
            around 70°F (20°C).
            """
        let string8 =
            """
            Try to avoid eating late in the evening
            as it may negatively affect both sleep
            quality and the natural release of
            your human growth hormone and melatonin.
            """
        let string9 =
            """
            We recommend relaxing and clearing your
            mind in the evening with strategies like
            listening to relaxing music, reading
            a book, taking a hot bath, meditating,
            deep breathing, and visualization.
            """
        let string10 =
            """
            We recommend taking a relaxing bath or
            shower for about 90 minutes or simply soak
            your feet in hot water before you sleep.
            """
        let string11 =
            """
            Try avoid drinking any liquids before bed
            and using the bathroom before bed.
            """
        let string12 =
            """
            Based on the time you are sleeping, we
            recommend reducing your consumption of
            caffeine late in the day. Studies show
            that even at 6 hours prior to bedtime,
            caffeine reduced sleep by more than 1 hour.
            """
        let string13 =
            """
            Try to sleep and wake at consistent times.
            """
        let string14 =
            """
            Try reducing your alcohol consumtion as
            it decreases the natural nighttime
            elevations in human growth hormone and
            alters your nighttime melatonin
            production, which both play a role in your
            circadian rhythm.
            """
        let string15 =
            """
            Based on your recorded mood, we
            recommend improving your quality of
            sleep by trying to increase bright light
            exposure during the day.
            """
        let string16 =
            """
            Try getting a comfortable bed, mattress,
            and pillow. We recommended that
            you upgrade your bedding at least every
            5–8 years.
            """
        let string17 =
            """
            Consider taking supplements including:
            melatonin, ginkgo biloba, glycine,
            valerian root, magnesium, l-theanine, and
            lavender supplements. Make sure to only
            try these supplements ONE at a time.
            """
        let string18 =
            """
            Based on sleep patterns, you may be
            suffering from insomina. If you are
            experienceing increasing exhaustion or
            an discomfort, we consulting a physcian
            for more information.
            """
        
        return [string0, string1, string2, string3,
                string4, string5, string6, string7,
                string8, string9, string10, string11,
                string12, string13, string14,
                string15, string16, string17, string18]
    }
    func noiseRec() -> [String]{
// noise recc
    let string0 =
        """
        We recommend reducing your
        environmental noise levels including
        music and television before bed to
        achieve the most peaceful sleep.
        """
    let string1 =
        """
        Try using earplug when you sleep to
        reduce your interuptions.
        """
    let string2 =
        """
        Based on your substantancial noise ambiance,
        we recommend installing sound insulation
        systems to improve your quality of sleep.
        """
    
    
    return [string0, string1, string2]
    }
    func heartRateRec() -> [String]{
// heart rate recc
    let string0 =
        """
        To decrease your resting heart rate we
        recommend to increase your physical
        activity.
        """
    let string1 =
        """
        With an increasing trend in resting heart
        rate, we recommend using stress reducing
        methods and sleeping before midnight.
        Increased resting heart rate can lead to
        higher risk of heart attacks and stroke.
        """
    let string2 =
        """
        A resting heart rate that is too low (less
        than 50 beats per minute), or one that is
        100 or higher, could be a sign of trouble
        and should prompt a call to your doctor.
        """
    return [string0, string1, string2]
    }
    func breathRateRec() -> [String]{
    // breathing rate recc
    let string0 =
        """
        The average resting respiratory rate for
        adults age 18-22 is 16-20 breaths per
        minute. Your respiratory rate may indicate
        serious medical conditions including sleep
        apnea. If you are experiencing any
        discomfort, we recommend consulting your
        physician for more information.
        """
    
    return [string0]
    }
    
    
    
    func OrderRecommendations(attribute: Int, difference: Double) -> [String]{
            var arr : [String] = []
            var i : Int = 0
            var diff = difference
            switch attribute{
            case 0: // hours of sleep - considers age
                if diff >= 0.875 {break}
                arr = SleepRec()
                diff = abs(diff-0.875)
                i = abs(Int(diff * Double(arr.count-1)))
                arr = Array(arr[0...i])
                break

            case 1: // noise ambiance
                if diff < 1.50 {break}
                diff = diff-1.50
                arr = noiseRec()
                if Int(diff * Double(arr.count-1)) > arr.count-1 {i=arr.count-1}
                else {i = abs(Int(diff * Double(arr.count-1)))}
                arr = Array(arr[0...i])
                break

            case 2: // heartRate - considers age
                if diff > 0.40 && diff < 1.40 {break}
                arr = heartRateRec()
                if diff < 0.40 {diff = abs(diff-0.40)}
                if diff > 1.40 {diff = abs(diff-1.40)}

                if Int(diff * Double(arr.count-1)) > arr.count-1 {i=arr.count-1}
                else {i = abs(Int(diff * Double(arr.count-1)))}
                i = abs(Int(diff * Double(arr.count-1)))
                arr = Array(arr[0...i])
                break

            case 3: // breathrate - considers age
                if diff > 0.75 && diff < 1.25 {break}
                arr = breathRateRec()
                if diff < 0.75 {diff = abs(diff-0.75)}
                if diff > 1.25 {diff = abs(diff-1.25)}

                i = abs(Int(diff * Double(arr.count-1)))
                arr = Array(arr[0...i])
                break
            default: break
            }
            return arr //typeRecArr //array of Strings to be appended in mainVC recommendationArr
        }
}

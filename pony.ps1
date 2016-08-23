#the powershell version of pony.bat, because I am bored.
$content_array = @(get-content listb.txt)

function roll_episode 
{
    $episode = $content_array[(get-random -Maximum ($content_array.length))]

    while (1) {
        if ($($episode.split(',')[1] -lt (get-random -Maximum 6))) {
            echo $episode.split(',')[0]
            break
        }
    }
}

while (1) {
    roll_episode
    if ($(read-host "Reroll?`n")[0] -ne 'y') {
        break
    }
}

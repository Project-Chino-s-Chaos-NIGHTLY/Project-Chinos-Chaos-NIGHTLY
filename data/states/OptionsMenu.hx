function postUpdate() {
    if (controls.LEFT_P || controls.RIGHT_P) {
        playMenuSong(ModOptions.menuTrack, false, true);
    }
}
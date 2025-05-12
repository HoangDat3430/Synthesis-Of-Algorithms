using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class UIEventBus
{
    public static Action<EventID> OnButtonClicked;
}
